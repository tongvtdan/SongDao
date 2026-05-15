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
  ],
  daos: [TodayDao, ActionLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

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
