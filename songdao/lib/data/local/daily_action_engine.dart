import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'user_settings_repository.dart';
import 'widget_snapshot_service.dart';

class DailyActionEngine {
  DailyActionEngine(this.db);

  final AppDatabase db;

  static const fallbackSourceRule = 'fallback_gentle_action';
  static const fallbackPrompt =
      'Bắt đầu nhẹ nhàng hôm nay: dành một phút thinh lặng và dâng ngày này cho Chúa.';
  static const fallbackType = 'prayer';
  static const fallbackPriority = 1000;

  Future<DailyAction> getOrCreateActionForDate(
    String date, {
    String locale = 'vi',
    bool publishWidgetSnapshot = true,
  }) async {
    final existing = await _existingAction(date, locale);
    if (existing != null) {
      final seededCalendar = await _calendarDay(date, locale);
      if (existing.sourceRule != fallbackSourceRule ||
          seededCalendar == null ||
          seededCalendar.season == 'unknown') {
        await WidgetSnapshotService(db).regenerateForDate(
          date,
          locale: locale,
          publishLatest: publishWidgetSnapshot,
        );
        return existing;
      }
    }

    final action = await db.transaction(() async {
      final insideTransactionExisting = await _existingAction(date, locale);
      var calendarDay = await _calendarDay(date, locale);
      final hasSeededCalendar =
          calendarDay != null && calendarDay.season != 'unknown';
      if (insideTransactionExisting != null &&
          (insideTransactionExisting.sourceRule != fallbackSourceRule ||
              !hasSeededCalendar)) {
        return insideTransactionExisting;
      }

      calendarDay ??= await _ensureFallbackCalendarDay(date, locale);

      final rule = hasSeededCalendar
          ? await _selectRule(calendarDay, _weekdayForDate(date))
          : null;
      final companion = rule == null
          ? _fallbackAction(date, locale)
          : _actionFromRule(date, locale, rule);

      await db.into(db.dailyActions).insertOnConflictUpdate(companion);
      return (await _existingAction(date, locale))!;
    });
    await WidgetSnapshotService(db).regenerateForDate(
      date,
      locale: locale,
      publishLatest: publishWidgetSnapshot,
    );
    return action;
  }

  Future<DailyAction?> _existingAction(String date, String locale) {
    return (db.select(db.dailyActions)
          ..where((t) => t.date.equals(date) & t.locale.equals(locale))
          ..orderBy([(t) => OrderingTerm.asc(t.priority)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<CalendarDay?> _calendarDay(String date, String locale) {
    return (db.select(db.calendarDays)
          ..where((t) => t.date.equals(date) & t.locale.equals(locale)))
        .getSingleOrNull();
  }

  Future<CalendarDay> _ensureFallbackCalendarDay(
    String date,
    String locale,
  ) async {
    await db
        .into(db.calendarDays)
        .insertOnConflictUpdate(
          CalendarDaysCompanion.insert(
            date: date,
            season: 'unknown',
            liturgicalWeek: 0,
            color: 'green',
            cycleYear: '',
            locale: locale,
          ),
        );
    return (await _calendarDay(date, locale))!;
  }

  Future<ActionRule?> _selectRule(CalendarDay day, String weekday) async {
    final celebrations =
        await (db.select(db.celebrations)..where(
              (t) => t.date.equals(day.date) & t.locale.equals(day.locale),
            ))
            .get();
    final context = _RuleContext(
      season: day.season,
      weekday: weekday,
      isSunday: weekday == 'sunday',
      isSolemnity: celebrations.any((item) => item.rank == 'solemnity'),
      isFeast: celebrations.any((item) => item.rank == 'feast'),
      isHolyDay: celebrations.any(
        (item) =>
            item.rank == 'holy_day' || item.rank == 'holy_day_of_obligation',
      ),
      hasParishEvent: false,
    );

    final rules =
        await (db.select(db.actionRules)
              ..where((t) => t.isActive.equals(true))
              ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
            .get();
    final activePackId = await _activePackIdForDate(day.date, day.locale);

    final matches = rules
        .where(
          (rule) =>
              (rule.locale == null || rule.locale == day.locale) &&
              (activePackId == null ||
                  rule.packId == null ||
                  rule.packId == activePackId) &&
              _matches(rule.triggerCondition, context),
        )
        .toList();
    if (matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) {
      final category = _ruleCategory(
        a.triggerCondition,
      ).compareTo(_ruleCategory(b.triggerCondition));
      if (category != 0) {
        return category;
      }
      return a.priority.compareTo(b.priority);
    });
    return matches.first;
  }

  Future<String?> _activePackIdForDate(String date, String locale) async {
    final setting =
        await (db.select(db.userSettings)..where(
              (t) =>
                  t.key.equals(UserSettingsKeys.activeCalendarContent(locale)),
            ))
            .getSingleOrNull();
    if (setting == null) {
      return null;
    }

    try {
      final scope = jsonDecode(setting.value);
      if (scope is! Map<String, Object?>) {
        return null;
      }
      final owner = scope[date];
      if (owner is! String) {
        return null;
      }
      final checksumSeparator = owner.indexOf('@');
      return checksumSeparator <= 0
          ? null
          : owner.substring(0, checksumSeparator);
    } on FormatException {
      return null;
    }
  }

  bool _matches(String conditionJson, _RuleContext context) {
    final condition = _decodeObject(conditionJson);
    return _fieldMatches(condition['season'], context.season) &&
        _fieldMatches(condition['weekday'], context.weekday) &&
        _fieldMatches(condition['is_sunday'], context.isSunday) &&
        _fieldMatches(condition['is_solemnity'], context.isSolemnity) &&
        _fieldMatches(condition['is_feast'], context.isFeast) &&
        _fieldMatches(condition['is_holy_day'], context.isHolyDay) &&
        _fieldMatches(condition['has_parish_event'], context.hasParishEvent);
  }

  bool _fieldMatches(Object? expected, Object actual) {
    if (expected == null) {
      return true;
    }
    return expected == actual;
  }

  int _ruleCategory(String conditionJson) {
    final condition = _decodeObject(conditionJson);
    if (condition['is_solemnity'] == true || condition['is_holy_day'] == true) {
      return 0;
    }
    if (condition['is_sunday'] == true || condition['weekday'] == 'sunday') {
      return 1;
    }
    if (condition['is_feast'] == true) {
      return 2;
    }
    if (condition['season'] != null) {
      return 3;
    }
    if (condition['has_parish_event'] == true) {
      return 4;
    }
    if (condition['weekday'] != null) {
      return 5;
    }
    return 6;
  }

  DailyActionsCompanion _actionFromRule(
    String date,
    String locale,
    ActionRule rule,
  ) {
    final action = _decodeObject(rule.templatePrompt);
    return DailyActionsCompanion.insert(
      id: _actionId(date, locale),
      date: date,
      sourceRule: rule.id,
      prompt: action['prompt'] as String? ?? fallbackPrompt,
      type: action['type'] as String? ?? rule.type,
      priority: rule.priority,
      locale: locale,
    );
  }

  DailyActionsCompanion _fallbackAction(String date, String locale) {
    return DailyActionsCompanion.insert(
      id: _actionId(date, locale),
      date: date,
      sourceRule: fallbackSourceRule,
      prompt: fallbackPrompt,
      type: fallbackType,
      priority: fallbackPriority,
      locale: locale,
    );
  }

  String _actionId(String date, String locale) =>
      'daily_action_${date}_$locale';

  Map<String, Object?> _decodeObject(String jsonSource) {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! Map) {
      return const {};
    }
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  String _weekdayForDate(String date) {
    final parsed = DateTime.parse(date);
    return const {
      DateTime.monday: 'monday',
      DateTime.tuesday: 'tuesday',
      DateTime.wednesday: 'wednesday',
      DateTime.thursday: 'thursday',
      DateTime.friday: 'friday',
      DateTime.saturday: 'saturday',
      DateTime.sunday: 'sunday',
    }[parsed.weekday]!;
  }
}

class _RuleContext {
  const _RuleContext({
    required this.season,
    required this.weekday,
    required this.isSunday,
    required this.isSolemnity,
    required this.isFeast,
    required this.isHolyDay,
    required this.hasParishEvent,
  });

  final String season;
  final String weekday;
  final bool isSunday;
  final bool isSolemnity;
  final bool isFeast;
  final bool isHolyDay;
  final bool hasParishEvent;
}
