import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../data/local/app_database.dart';
import '../../data/local/daily_action_engine.dart';
import '../../data/local/mass_service.dart';
import '../../data/local/user_settings_repository.dart';

class TodayController {
  const TodayController({
    required this.db,
    required this.settings,
    required this.engine,
    required this.massService,
  });

  final AppDatabase db;
  final UserSettingsRepository settings;
  final DailyActionEngine engine;
  final MassService massService;

  Future<TodayViewData> load({String? date}) async {
    final dateKey = date ?? todayDateKey();
    final locale = await settings.locale();
    final showLunarDate = await settings.showLunarDate();
    final action = await engine.getOrCreateActionForDate(
      dateKey,
      locale: locale,
    );
    final calendarDay =
        await (db.select(db.calendarDays)..where(
              (t) => t.date.equals(dateKey) & t.locale.equals(action.locale),
            ))
            .getSingle();
    final celebrations =
        await (db.select(db.celebrations)
              ..where(
                (t) => t.date.equals(dateKey) & t.locale.equals(action.locale),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
            .get();
    final readings =
        await (db.select(db.readings)..where(
              (t) => t.date.equals(dateKey) & t.locale.equals(action.locale),
            ))
            .get();
    readings.sort(
      (a, b) => readingOrder(a.type).compareTo(readingOrder(b.type)),
    );
    final log = await db.todayDao.getActionLogForAction(action.id);
    final importantMass = await massService.nextImportantMassForDate(dateKey);
    final reflection =
        await (db.select(db.dailyReflections)..where(
              (t) => t.date.equals(dateKey) & t.locale.equals(action.locale),
            ))
            .getSingleOrNull();

    return TodayViewData(
      date: dateKey,
      locale: locale,
      showLunarDate: showLunarDate,
      calendarDay: calendarDay,
      celebrations: celebrations,
      readings: readings,
      action: action,
      log: log,
      importantMass: importantMass,
      reflection: reflection,
    );
  }

  Future<void> completeAction(TodayViewData data, {String? note}) {
    final trimmed = note?.trim();
    return db.actionLogDao.markCompleted(
      data.action.id,
      note: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  Future<void> saveNote(TodayViewData data, String note) {
    return db.actionLogDao.saveNote(data.action.id, note.trim());
  }

  static String todayDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}

class TodayViewData {
  const TodayViewData({
    required this.date,
    required this.locale,
    required this.showLunarDate,
    required this.calendarDay,
    required this.celebrations,
    required this.readings,
    required this.action,
    required this.log,
    required this.importantMass,
    required this.reflection,
  });

  final String date;
  final String locale;
  final bool showLunarDate;
  final CalendarDay calendarDay;
  final List<Celebration> celebrations;
  final List<Reading> readings;
  final DailyAction action;
  final ActionLog? log;
  final ImportantMass? importantMass;
  final DailyReflection? reflection;
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
