import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables/action_logs.dart';
import 'tables/action_rules.dart';
import 'tables/calendar_days.dart';
import 'tables/celebrations.dart';
import 'tables/churches.dart';
import 'tables/daily_actions.dart';
import 'tables/daily_reflections.dart';
import 'tables/mass_times.dart';
import 'tables/prayers.dart';
import 'tables/readings.dart';
import 'tables/user_settings.dart';
import 'tables/user_events.dart';
import 'tables/widget_snapshots.dart';
import 'daos/action_log_dao.dart';
import 'daos/today_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CalendarDays,
    Celebrations,
    Readings,
    ActionRules,
    DailyActions,
    DailyReflections,
    ActionLogs,
    UserSettings,
    WidgetSnapshots,
    Churches,
    MassTimes,
    Prayers,
    UserEvents,
  ],
  daos: [TodayDao, ActionLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(actionLogs, actionLogs.status);
        await m.addColumn(actionLogs, actionLogs.createdAt);
        await m.createTable(celebrations);
        await m.createTable(readings);
        await m.createTable(actionRules);
        await m.createTable(userSettings);
        await m.createTable(widgetSnapshots);
      }
      if (from < 3) {
        await m.alterTable(
          TableMigration(
            dailyActions,
            newColumns: [dailyActions.locale, dailyActions.createdAt],
            columnTransformer: {
              dailyActions.locale: const Constant('vi'),
              dailyActions.createdAt: currentDateAndTime,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            actionLogs,
            newColumns: [actionLogs.date, actionLogs.updatedAt],
            columnTransformer: {
              actionLogs.date: const Constant(''),
              actionLogs.updatedAt: currentDateAndTime,
            },
          ),
        );
      }
      if (from < 4) {
        await m.addColumn(calendarDays, calendarDays.lunarDate);
        await m.createTable(churches);
        await m.createTable(massTimes);
        await m.createTable(prayers);
      }
      if (from < 5) {
        await m.createTable(dailyReflections);
      }
      if (from < 6) {
        await m.addColumn(churches, churches.timezone);
      }
      if (from < 7) {
        await m.database.customStatement('''
          CREATE TABLE calendar_days_v7 (
            date TEXT NOT NULL,
            season TEXT NOT NULL,
            liturgical_week INTEGER NOT NULL,
            color TEXT NOT NULL,
            cycle_year TEXT NOT NULL,
            locale TEXT NOT NULL,
            lunar_date TEXT,
            PRIMARY KEY (date, locale)
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO calendar_days_v7
            (date, season, liturgical_week, color, cycle_year, locale, lunar_date)
          SELECT date, season, liturgical_week, color, cycle_year, locale, lunar_date
          FROM calendar_days
        ''');
        await m.database.customStatement('PRAGMA foreign_keys = OFF');
        try {
          await m.database.customStatement('DROP TABLE calendar_days');
          await m.database.customStatement(
            'ALTER TABLE calendar_days_v7 RENAME TO calendar_days',
          );
        } finally {
          await m.database.customStatement('PRAGMA foreign_keys = ON');
        }
      }
      if (from < 8) {
        await m.createTable(userEvents);
      }
      if (from >= 8 && from < 9) {
        await m.addColumn(userEvents, userEvents.eventHour);
        await m.addColumn(userEvents, userEvents.eventMinute);
        await m.addColumn(userEvents, userEvents.reminderOffsetMinutes);
        await m.addColumn(userEvents, userEvents.color);
        await m.database.customStatement('''
          UPDATE user_events
          SET reminder_offset_minutes = reminder_offset_days * 1440
          WHERE reminder_offset_days IS NOT NULL
        ''');
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'songdao.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
