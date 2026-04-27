import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_importer.dart';
import 'package:songdao/data/local/app_database.dart';

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('ActionLogs', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('inserts and reads an action log', () async {
      await db
          .into(db.calendarDays)
          .insert(
            CalendarDaysCompanion.insert(
              date: '2026-04-27',
              season: 'ordinary',
              liturgicalWeek: 4,
              color: 'green',
              cycleYear: 'C',
              locale: 'vi',
            ),
          );

      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'action-1',
              date: '2026-04-27',
              sourceRule: 'morning_prayer',
              prompt: 'Đọc kinh sáng',
              type: 'prayer',
              priority: 1,
              locale: 'vi',
            ),
          );

      await db
          .into(db.actionLogs)
          .insert(
            ActionLogsCompanion.insert(
              id: 'log-1',
              actionId: 'action-1',
              date: '2026-04-27',
            ),
          );

      final log = await (db.select(
        db.actionLogs,
      )..where((t) => t.id.equals('log-1'))).getSingle();

      expect(log.id, 'log-1');
      expect(log.actionId, 'action-1');
      expect(log.status, 'pending');
      expect(log.completedAt, isNull);
      expect(log.note, isNull);
    });

    test('updates status to completed with timestamp and note', () async {
      await db
          .into(db.calendarDays)
          .insert(
            CalendarDaysCompanion.insert(
              date: '2026-04-27',
              season: 'ordinary',
              liturgicalWeek: 4,
              color: 'green',
              cycleYear: 'C',
              locale: 'vi',
            ),
          );

      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'action-2',
              date: '2026-04-27',
              sourceRule: 'evening_prayer',
              prompt: 'Đọc kinh tối',
              type: 'prayer',
              priority: 2,
              locale: 'vi',
            ),
          );

      await db
          .into(db.actionLogs)
          .insert(
            ActionLogsCompanion.insert(
              id: 'log-2',
              actionId: 'action-2',
              date: '2026-04-27',
            ),
          );

      final now = DateTime.now();
      await (db.update(
        db.actionLogs,
      )..where((t) => t.id.equals('log-2'))).write(
        ActionLogsCompanion(
          status: const Value('completed'),
          completedAt: Value(now),
          note: const Value('Hoàn thành tốt'),
        ),
      );

      final updated = await (db.select(
        db.actionLogs,
      )..where((t) => t.id.equals('log-2'))).getSingle();

      expect(updated.status, 'completed');
      expect(updated.completedAt, isNotNull);
      expect(updated.note, 'Hoàn thành tốt');
    });

    test('ActionLogDao.markCompleted creates log when none exists', () async {
      await db
          .into(db.calendarDays)
          .insert(
            CalendarDaysCompanion.insert(
              date: '2026-04-27',
              season: 'ordinary',
              liturgicalWeek: 4,
              color: 'green',
              cycleYear: 'C',
              locale: 'vi',
            ),
          );

      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'action-3',
              date: '2026-04-27',
              sourceRule: 'reading',
              prompt: 'Đọc Tin Mừng',
              type: 'reading',
              priority: 1,
              locale: 'vi',
            ),
          );

      await db.actionLogDao.markCompleted('action-3', note: 'Đã đọc xong');

      final log = await (db.select(
        db.actionLogs,
      )..where((t) => t.actionId.equals('action-3'))).getSingle();

      expect(log.status, 'completed');
      expect(log.completedAt, isNotNull);
      expect(log.note, 'Đã đọc xong');
    });

    test(
      'ActionLogDao.getLogsForDate returns logs for the given date',
      () async {
        await db
            .into(db.calendarDays)
            .insert(
              CalendarDaysCompanion.insert(
                date: '2026-04-27',
                season: 'ordinary',
                liturgicalWeek: 4,
                color: 'green',
                cycleYear: 'C',
                locale: 'vi',
              ),
            );

        await db
            .into(db.dailyActions)
            .insert(
              DailyActionsCompanion.insert(
                id: 'action-4',
                date: '2026-04-27',
                sourceRule: 'prayer',
                prompt: 'Cầu nguyện',
                type: 'prayer',
                priority: 1,
                locale: 'vi',
              ),
            );

        await db.actionLogDao.markCompleted('action-4');

        final logs = await db.actionLogDao.getLogsForDate('2026-04-27');
        expect(logs, hasLength(1));
        expect(logs.first.status, 'completed');
        expect(logs.first.date, '2026-04-27');
      },
    );

    test('prevents duplicate logs for the same action', () async {
      await db
          .into(db.calendarDays)
          .insert(
            CalendarDaysCompanion.insert(
              date: '2026-04-27',
              season: 'ordinary',
              liturgicalWeek: 4,
              color: 'green',
              cycleYear: 'C',
              locale: 'vi',
            ),
          );

      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'action-5',
              date: '2026-04-27',
              sourceRule: 'prayer',
              prompt: 'Cầu nguyện',
              type: 'prayer',
              priority: 1,
              locale: 'vi',
            ),
          );

      await db
          .into(db.actionLogs)
          .insert(
            ActionLogsCompanion.insert(
              id: 'log-5a',
              actionId: 'action-5',
              date: '2026-04-27',
            ),
          );

      expect(
        () => db
            .into(db.actionLogs)
            .insert(
              ActionLogsCompanion.insert(
                id: 'log-5b',
                actionId: 'action-5',
                date: '2026-04-27',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'ActionLogDao.markCompleted updates existing log instead of duplicating',
      () async {
        await db
            .into(db.calendarDays)
            .insert(
              CalendarDaysCompanion.insert(
                date: '2026-04-27',
                season: 'ordinary',
                liturgicalWeek: 4,
                color: 'green',
                cycleYear: 'C',
                locale: 'vi',
              ),
            );

        await db
            .into(db.dailyActions)
            .insert(
              DailyActionsCompanion.insert(
                id: 'action-6',
                date: '2026-04-27',
                sourceRule: 'reading',
                prompt: 'Đọc Tin Mừng',
                type: 'reading',
                priority: 1,
                locale: 'vi',
              ),
            );

        await db.actionLogDao.markCompleted('action-6', note: 'Lần đầu');
        await db.actionLogDao.markCompleted('action-6', note: 'Cập nhật');

        final logs = await db.select(db.actionLogs).get();
        expect(logs, hasLength(1));
        expect(logs.single.status, 'completed');
        expect(logs.single.note, 'Cập nhật');
      },
    );
  });

  group('Readings', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('stores citation with nullable text and licensing metadata', () async {
      await db
          .into(db.calendarDays)
          .insert(
            CalendarDaysCompanion.insert(
              date: '2026-04-27',
              season: 'easter',
              liturgicalWeek: 2,
              color: 'white',
              cycleYear: 'C',
              locale: 'vi',
            ),
          );

      await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              id: 'reading-2026-04-27-gospel-vi',
              date: '2026-04-27',
              type: 'gospel',
              citation: 'Ga 3,1-8',
              displayLabel: const Value('Tin Mừng'),
              textContent: const Value.absent(),
              sourceUrl: const Value('https://example.org/readings/2026-04-27'),
              license: 'reference-only',
              locale: 'vi',
            ),
          );

      final reading = await db.select(db.readings).getSingle();
      expect(reading.citation, 'Ga 3,1-8');
      expect(reading.displayLabel, 'Tin Mừng');
      expect(reading.textContent, isNull);
      expect(reading.sourceUrl, 'https://example.org/readings/2026-04-27');
      expect(reading.license, 'reference-only');
    });
  });

  group('UserSettings', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('inserts and reads a setting', () async {
      await db
          .into(db.userSettings)
          .insert(UserSettingsCompanion.insert(key: 'locale', value: 'vi'));

      final setting = await (db.select(
        db.userSettings,
      )..where((t) => t.key.equals('locale'))).getSingle();

      expect(setting.key, 'locale');
      expect(setting.value, 'vi');
    });

    test('updates an existing setting', () async {
      await db
          .into(db.userSettings)
          .insert(
            UserSettingsCompanion.insert(key: 'notifications', value: 'true'),
          );

      await (db.update(
        db.userSettings,
      )..where((t) => t.key.equals('notifications'))).write(
        UserSettingsCompanion(
          value: const Value('false'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updated = await (db.select(
        db.userSettings,
      )..where((t) => t.key.equals('notifications'))).getSingle();

      expect(updated.value, 'false');
    });

    test('upsert overwrites on duplicate key', () async {
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(key: 'theme', value: 'light'),
          );
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(key: 'theme', value: 'dark'),
          );

      final all = await db.select(db.userSettings).get();
      expect(all.where((s) => s.key == 'theme'), hasLength(1));
      expect(all.firstWhere((s) => s.key == 'theme').value, 'dark');
    });
  });

  group('ContentPackImporter', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test(
      'imports the 14-day demo pack transactionally and idempotently',
      () async {
        final source = await File(
          '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
        ).readAsString();
        final importer = ContentPackImporter(db);

        final firstResult = await importer.importPackJson(source);
        final secondResult = await importer.importPackJson(source);

        expect(firstResult.packId, 'calendar-vn-demo-2026');
        expect(firstResult.imported, isTrue);
        expect(secondResult.imported, isFalse);
        expect(await db.select(db.calendarDays).get(), hasLength(14));
        expect(await db.select(db.celebrations).get(), hasLength(14));
        expect(await db.select(db.readings).get(), hasLength(31));
        expect(await db.select(db.actionRules).get(), hasLength(5));

        final readings = await db.select(db.readings).get();
        expect(
          readings.every((reading) => reading.textContent == null),
          isTrue,
        );

        final manifest =
            await (db.select(db.userSettings)
                  ..where((t) => t.key.equals('active_content_pack_manifest')))
                .getSingle();
        expect(manifest.value, contains('calendar-vn-demo-2026'));
      },
    );
  });
}
