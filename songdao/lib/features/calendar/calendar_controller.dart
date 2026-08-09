import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../data/local/app_database.dart';
import '../../data/local/daily_action_engine.dart';
import '../../data/local/event_reminder_service.dart';
import '../../data/local/user_event_repository.dart';
import '../../data/local/user_settings_repository.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({
    required AppDatabase database,
    required UserSettingsRepository settings,
    required DailyActionEngine dailyActionEngine,
    required UserEventRepository userEvents,
    required EventReminderService eventReminders,
    required Future<void> Function() bootstrapContent,
    required VoidCallback invalidateBootstrap,
    DateTime? initialDate,
    int? focusedEventId,
  }) : this._(
         database,
         settings,
         dailyActionEngine,
         userEvents,
         eventReminders,
         bootstrapContent,
         invalidateBootstrap,
         initialDate ?? DateTime.now(),
         focusedEventId,
       );

  CalendarController._(
    this._database,
    this._settings,
    this._dailyActionEngine,
    this._userEvents,
    this._eventReminders,
    this._bootstrapContent,
    this._invalidateBootstrap,
    DateTime initialDate,
    this._focusedEventId,
  ) : _selectedDate = _dateOnly(initialDate),
      _visibleMonth = DateTime(initialDate.year, initialDate.month);

  final AppDatabase _database;
  final UserSettingsRepository _settings;
  final DailyActionEngine _dailyActionEngine;
  final UserEventRepository _userEvents;
  final EventReminderService _eventReminders;
  final Future<void> Function() _bootstrapContent;
  final VoidCallback _invalidateBootstrap;
  final int? _focusedEventId;

  DateTime _visibleMonth;
  DateTime _selectedDate;
  CalendarState? _data;
  Object? _error;
  bool _isLoading = false;
  bool _resolvedFocusedEvent = false;

  DateTime get visibleMonth => _visibleMonth;
  DateTime get selectedDate => _selectedDate;
  CalendarState? get data => _data;
  Object? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    if (!_resolvedFocusedEvent && _focusedEventId != null) {
      _resolvedFocusedEvent = true;
      final event = await _userEvents.getById(_focusedEventId);
      if (event != null) {
        final occurrence = _userEvents.nextOccurrenceOnOrAfter(
          event,
          DateTime.now(),
        );
        final date = occurrence?.date ?? _userEvents.anchorDateFor(event);
        _selectedDate = _dateOnly(date);
        _visibleMonth = DateTime(date.year, date.month);
      }
    }
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      var liturgicalBootstrapFailed = false;
      try {
        await _bootstrapContent();
      } on Object {
        liturgicalBootstrapFailed = true;
      }
      _data = await _loadData(
        liturgicalBootstrapFailed: liturgicalBootstrapFailed,
      );
    } on Object catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLiturgicalContent() async {
    _invalidateBootstrap();
    await load();
  }

  Future<void> changeMonth(int delta) async {
    final target = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    _visibleMonth = target;
    _selectedDate = DateTime(
      target.year,
      target.month,
      math.min(_selectedDate.day, lastDay),
    );
    await load();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = _dateOnly(date);
    if (date.year != _visibleMonth.year || date.month != _visibleMonth.month) {
      _visibleMonth = DateTime(date.year, date.month);
    }
    await load();
  }

  Future<void> deleteEvent(int eventId) async {
    await _userEvents.deleteEvent(eventId);
    await _eventReminders.refreshScheduledReminders();
    await load();
  }

  Future<CalendarState> _loadData({
    required bool liturgicalBootstrapFailed,
  }) async {
    final locale = await _settings.locale();
    final showLunarDate = await _settings.showLunarDate();
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final gridStart = first.subtract(Duration(days: first.weekday % 7));
    final gridEnd = gridStart.add(const Duration(days: 41));

    final days =
        await (_database.select(_database.calendarDays)
              ..where(
                (table) =>
                    table.date.isBiggerOrEqualValue(dateKey(gridStart)) &
                    table.date.isSmallerOrEqualValue(dateKey(gridEnd)) &
                    table.locale.equals(locale),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.date)]))
            .get();
    final selectedKey = dateKey(_selectedDate);
    final selectedDay =
        await (_database.select(_database.calendarDays)..where(
              (table) =>
                  table.date.equals(selectedKey) & table.locale.equals(locale),
            ))
            .getSingleOrNull();
    final celebrations =
        await (_database.select(_database.celebrations)
              ..where(
                (table) =>
                    table.date.equals(selectedKey) &
                    table.locale.equals(locale),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.rank)]))
            .get();
    final readings =
        await (_database.select(_database.readings)..where(
              (table) =>
                  table.date.equals(selectedKey) & table.locale.equals(locale),
            ))
            .get();
    readings.sort(
      (a, b) => readingOrder(a.type).compareTo(readingOrder(b.type)),
    );

    DailyAction? action;
    if (selectedDay != null) {
      action = await _dailyActionEngine.getOrCreateActionForDate(
        selectedKey,
        locale: locale,
      );
    }
    final reflection =
        await (_database.select(_database.dailyReflections)..where(
              (table) =>
                  table.date.equals(selectedKey) & table.locale.equals(locale),
            ))
            .getSingleOrNull();
    final occurrences = await _userEvents.occurrencesBetween(
      gridStart,
      gridEnd,
    );
    final occurrencesByDate = <String, List<UserEventOccurrence>>{};
    for (final occurrence in occurrences) {
      occurrencesByDate
          .putIfAbsent(dateKey(occurrence.date), () => [])
          .add(occurrence);
    }
    final selectedEvents = await _userEvents.occurrencesOn(_selectedDate);

    return CalendarState(
      locale: locale,
      showLunarDate: showLunarDate,
      liturgicalBootstrapFailed: liturgicalBootstrapFailed,
      days: {for (final day in days) day.date: day},
      occurrencesByDate: occurrencesByDate,
      selectedDay: selectedDay,
      selectedEvents: selectedEvents,
      celebrations: celebrations,
      readings: readings,
      action: action,
      reflection: reflection,
    );
  }
}

class CalendarState {
  const CalendarState({
    required this.locale,
    required this.showLunarDate,
    required this.liturgicalBootstrapFailed,
    required this.days,
    required this.occurrencesByDate,
    required this.selectedDay,
    required this.selectedEvents,
    required this.celebrations,
    required this.readings,
    required this.action,
    required this.reflection,
  });

  final String locale;
  final bool showLunarDate;
  final bool liturgicalBootstrapFailed;
  final Map<String, CalendarDay> days;
  final Map<String, List<UserEventOccurrence>> occurrencesByDate;
  final CalendarDay? selectedDay;
  final List<UserEventOccurrence> selectedEvents;
  final List<Celebration> celebrations;
  final List<Reading> readings;
  final DailyAction? action;
  final DailyReflection? reflection;
}

String dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

int readingOrder(String type) {
  return switch (type) {
    'first' || 'first_reading' => 0,
    'psalm' => 1,
    'second' || 'second_reading' => 2,
    'alleluia' || 'gospel_acclamation' => 3,
    'gospel' => 4,
    _ => 5,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
