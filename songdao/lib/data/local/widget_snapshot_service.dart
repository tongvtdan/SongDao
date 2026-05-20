import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'mass_service.dart';
import 'widget_snapshot_bridge.dart';

class WidgetSnapshotService {
  WidgetSnapshotService(
    this.db, {
    WidgetSnapshotBridge bridge = const WidgetSnapshotBridge(),
  }) : _bridge = bridge;

  final AppDatabase db;
  final WidgetSnapshotBridge _bridge;

  Future<WidgetSnapshot?> regenerateForDate(
    String date, {
    String locale = 'vi',
    bool publishLatest = true,
  }) async {
    final calendarDay =
        await (db.select(db.calendarDays)
              ..where((t) => t.date.equals(date) & t.locale.equals(locale)))
            .getSingleOrNull();
    final action =
        await (db.select(db.dailyActions)
              ..where((t) => t.date.equals(date) & t.locale.equals(locale))
              ..orderBy([(t) => OrderingTerm.asc(t.priority)])
              ..limit(1))
            .getSingleOrNull();

    if (calendarDay == null || action == null) {
      return null;
    }

    final celebrations =
        await (db.select(db.celebrations)
              ..where((t) => t.date.equals(date) & t.locale.equals(locale))
              ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
            .get();
    final readings = await (db.select(
      db.readings,
    )..where((t) => t.date.equals(date) & t.locale.equals(locale))).get();
    readings.sort(
      (a, b) => _readingSortValue(a.type).compareTo(_readingSortValue(b.type)),
    );
    final log = await (db.select(
      db.actionLogs,
    )..where((t) => t.actionId.equals(action.id))).getSingleOrNull();
    final importantMass = await MassService(db).nextImportantMassForDate(date);
    final dailyQuote = _dailyQuoteFor(date);
    final primaryCelebration = celebrations.isEmpty
        ? null
        : celebrations.first.name;

    final now = DateTime.now().toUtc();
    final payload = _canonicalJson({
      'schema_version': 1,
      'date': date,
      'locale': locale,
      'generated_at': now.toIso8601String(),
      'liturgical_context': {
        'season': calendarDay.season,
        'color': calendarDay.color,
        'liturgical_week': calendarDay.liturgicalWeek,
        'cycle_year': calendarDay.cycleYear,
        'lunar_date': locale == 'vi' ? calendarDay.lunarDate : null,
        'celebration': primaryCelebration,
      },
      'daily_quote': {
        'text': dailyQuote.text,
        'attribution': dailyQuote.attribution,
      },
      'saint_of_day': _saintOfDayLabel(celebrations),
      'action': {
        'id': action.id,
        'type': action.type,
        'prompt': action.prompt,
        'completed': log?.status == 'completed',
        'status': log?.status ?? 'pending',
      },
      'readings': readings
          .map(
            (reading) => {
              'type': reading.type,
              'label': reading.displayLabel ?? _readingLabel(reading.type),
              'citation': reading.citation,
            },
          )
          .toList(growable: false),
      'mass': importantMass == null
          ? null
          : {
              'church': importantMass.church.name,
              'time': importantMass.massTime.time,
              'language': importantMass.massTime.language,
              'label': importantMass.label,
            },
    });

    await db.todayDao.upsertWidgetSnapshot(
      WidgetSnapshotsCompanion.insert(
        date: date,
        payload: payload,
        generatedAt: now,
      ),
    );
    final snapshot = await db.todayDao.getWidgetSnapshot(date);
    if (snapshot != null && publishLatest && date == _dateKey(DateTime.now())) {
      await _bridge.writeLatestSnapshot(date: date, payload: snapshot.payload);
    }
    return snapshot;
  }

  Future<void> regenerateRange({
    required DateTime startDate,
    int days = 14,
    String locale = 'vi',
  }) async {
    for (var offset = 0; offset < days; offset += 1) {
      final date = _dateKey(startDate.add(Duration(days: offset)));
      await regenerateForDate(
        date,
        locale: locale,
        publishLatest: date == _dateKey(DateTime.now()),
      );
    }
  }

  int _readingSortValue(String type) {
    return switch (type) {
      'first_reading' => 0,
      'psalm' => 1,
      'second_reading' => 2,
      'gospel_acclamation' => 3,
      'gospel' => 4,
      _ => 99,
    };
  }

  String _readingLabel(String type) {
    return switch (type) {
      'first_reading' => 'Bài đọc I',
      'psalm' => 'Thánh vịnh',
      'second_reading' => 'Bài đọc II',
      'gospel_acclamation' => 'Alleluia',
      'gospel' => 'Tin Mừng',
      _ => 'Bài đọc',
    };
  }

  _WidgetDailyQuote _dailyQuoteFor(String date) {
    final parsed = DateTime.parse(date);
    final startOfYear = DateTime(parsed.year);
    final dayOfYear = parsed.difference(startOfYear).inDays + 1;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  String? _saintOfDayLabel(List<Celebration> celebrations) {
    for (final celebration in celebrations) {
      final rank = celebration.rank;
      final name = celebration.name;
      final isSaint =
          name.startsWith('Thánh ') || name.startsWith('Các Thánh ');
      final isRankedSaint =
          rank == 'memorial' || rank == 'optional_memorial' || rank == 'feast';

      if (isSaint && isRankedSaint) {
        return name;
      }
    }
    return null;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _canonicalJson(Map<String, Object?> value) {
    return jsonEncode(_canonicalValue(value));
  }

  Object? _canonicalValue(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _canonicalValue(value[key]);
      }
      return sorted;
    }
    if (value is List) {
      return value.map(_canonicalValue).toList(growable: false);
    }
    return value;
  }
}

class _WidgetDailyQuote {
  const _WidgetDailyQuote({required this.text, required this.attribution});

  final String text;
  final String attribution;
}

const _dailyQuotes = [
  _WidgetDailyQuote(
    text: 'Một việc nhỏ được làm với lòng yêu mến có thể đổi hướng cả ngày.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Bình an bắt đầu khi con trao cho Chúa điều con không tự giữ nổi.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Đức tin lớn lên trong những lựa chọn rất nhỏ và rất thật.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Hãy bắt đầu lại nhẹ nhàng; lòng thương xót luôn đi trước con.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Yêu thương hôm nay không cần lớn tiếng, chỉ cần cụ thể.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Một phút thinh lặng có thể mở lại cánh cửa của lòng mình.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _WidgetDailyQuote(
    text: 'Chúa thường gặp ta trong bổn phận nhỏ đang ở ngay trước mặt.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
];
