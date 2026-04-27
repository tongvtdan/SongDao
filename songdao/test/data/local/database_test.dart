import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/local/app_database.dart';

AppDatabase _openTestDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('ActionLogs', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('inserts and reads an action log', () async {
      await db.into(db.calendarDays).insert(CalendarDaysCompanion.insert(
            date: '2026-04-27',
            season: 'ordinary',
            liturgicalWeek: 4,
            color: 'green',
            cycleYear: 'C',
            locale: 'vi',
          ));

      await db.into(db.dailyActions).insert(DailyActionsCompanion.insert(
            id: 'action-1',
            date: '2026-04-27',
            sourceRule: 'morning_prayer',
            prompt: 'Đọc kinh sáng',
            type: 'prayer',
            priority: 1,
          ));

      await db.into(db.actionLogs).insert(ActionLogsCompanion.insert(
            id: 'log-1',
            actionId: 'action-1',
          ));

      final log = await (db.select(db.actionLogs)
            ..where((t) => t.id.equals('log-1')))
          .getSingle();

      expect(log.id, 'log-1');
      expect(log.actionId, 'action-1');
      expect(log.status, 'pending');
      expect(log.completedAt, isNull);
      expect(log.note, isNull);
    });

    test('updates status to completed with timestamp and note', () async {
      await db.into(db.calendarDays).insert(CalendarDaysCompanion.insert(
            date: '2026-04-27',
            season: 'ordinary',
            liturgicalWeek: 4,
            color: 'green',
            cycleYear: 'C',
            locale: 'vi',
          ));

      await db.into(db.dailyActions).insert(DailyActionsCompanion.insert(
            id: 'action-2',
            date: '2026-04-27',
            sourceRule: 'evening_prayer',
            prompt: 'Đọc kinh tối',
            type: 'prayer',
            priority: 2,
          ));

      await db.into(db.actionLogs).insert(ActionLogsCompanion.insert(
            id: 'log-2',
            actionId: 'action-2',
          ));

      final now = DateTime.now();
      await (db.update(db.actionLogs)..where((t) => t.id.equals('log-2')))
          .write(ActionLogsCompanion(
        status: const Value('completed'),
        completedAt: Value(now),
        note: const Value('Hoàn thành tốt'),
      ));

      final updated = await (db.select(db.actionLogs)
            ..where((t) => t.id.equals('log-2')))
          .getSingle();

      expect(updated.status, 'completed');
      expect(updated.completedAt, isNotNull);
      expect(updated.note, 'Hoàn thành tốt');
    });

    test('ActionLogDao.markCompleted creates log when none exists', () async {
      await db.into(db.calendarDays).insert(CalendarDaysCompanion.insert(
            date: '2026-04-27',
            season: 'ordinary',
            liturgicalWeek: 4,
            color: 'green',
            cycleYear: 'C',
            locale: 'vi',
          ));

      await db.into(db.dailyActions).insert(DailyActionsCompanion.insert(
            id: 'action-3',
            date: '2026-04-27',
            sourceRule: 'reading',
            prompt: 'Đọc Tin Mừng',
            type: 'reading',
            priority: 1,
          ));

      await db.actionLogDao.markCompleted('action-3', note: 'Đã đọc xong');

      final log = await (db.select(db.actionLogs)
            ..where((t) => t.actionId.equals('action-3')))
          .getSingle();

      expect(log.status, 'completed');
      expect(log.completedAt, isNotNull);
      expect(log.note, 'Đã đọc xong');
    });

    test('ActionLogDao.getLogsForDate returns logs for the given date',
        () async {
      await db.into(db.calendarDays).insert(CalendarDaysCompanion.insert(
            date: '2026-04-27',
            season: 'ordinary',
            liturgicalWeek: 4,
            color: 'green',
            cycleYear: 'C',
            locale: 'vi',
          ));

      await db.into(db.dailyActions).insert(DailyActionsCompanion.insert(
            id: 'action-4',
            date: '2026-04-27',
            sourceRule: 'prayer',
            prompt: 'Cầu nguyện',
            type: 'prayer',
            priority: 1,
          ));

      await db.actionLogDao.markCompleted('action-4');

      final logs = await db.actionLogDao.getLogsForDate('2026-04-27');
      expect(logs, hasLength(1));
      expect(logs.first.status, 'completed');
    });
  });

  group('UserSettings', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('inserts and reads a setting', () async {
      await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
            key: 'locale',
            value: 'vi',
          ));

      final setting = await (db.select(db.userSettings)
            ..where((t) => t.key.equals('locale')))
          .getSingle();

      expect(setting.key, 'locale');
      expect(setting.value, 'vi');
    });

    test('updates an existing setting', () async {
      await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
            key: 'notifications',
            value: 'true',
          ));

      await (db.update(db.userSettings)
            ..where((t) => t.key.equals('notifications')))
          .write(UserSettingsCompanion(
        value: const Value('false'),
        updatedAt: Value(DateTime.now()),
      ));

      final updated = await (db.select(db.userSettings)
            ..where((t) => t.key.equals('notifications')))
          .getSingle();

      expect(updated.value, 'false');
    });

    test('upsert overwrites on duplicate key', () async {
      await db.into(db.userSettings).insertOnConflictUpdate(
            UserSettingsCompanion.insert(key: 'theme', value: 'light'),
          );
      await db.into(db.userSettings).insertOnConflictUpdate(
            UserSettingsCompanion.insert(key: 'theme', value: 'dark'),
          );

      final all = await db.select(db.userSettings).get();
      expect(all.where((s) => s.key == 'theme'), hasLength(1));
      expect(all.firstWhere((s) => s.key == 'theme').value, 'dark');
    });
  });
}
