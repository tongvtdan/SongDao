import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_importer.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/daily_action_engine.dart';
import 'package:songdao/data/local/mass_service.dart';
import 'package:songdao/data/local/user_settings_repository.dart';
import 'package:songdao/data/local/widget_snapshot_bridge.dart';
import 'package:songdao/data/local/widget_snapshot_service.dart';

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyActionEngine', () {
    late AppDatabase db;
    late DailyActionEngine engine;

    setUp(() {
      db = _openTestDb();
      engine = DailyActionEngine(db);
    });
    tearDown(() => db.close());

    test('selects Sunday action before seasonal action', () async {
      await _insertCalendarDay(db, '2026-05-03', season: 'easter');
      await _insertRule(
        db,
        id: 'easter_weekday_gospel_note_vi',
        priority: 50,
        when: {'season': 'easter', 'is_sunday': false},
        action: {
          'type': 'reflection',
          'prompt': 'Viết một câu về Tin Mừng hôm nay.',
        },
      );
      await _insertRule(
        db,
        id: 'sunday_mass_intention_vi',
        priority: 20,
        when: {'weekday': 'sunday', 'is_sunday': true},
        action: {
          'type': 'mass_preparation',
          'prompt': 'Chuẩn bị một ý nguyện trước Thánh lễ.',
        },
      );

      final action = await engine.getOrCreateActionForDate('2026-05-03');

      expect(action.sourceRule, 'sunday_mass_intention_vi');
      expect(action.type, 'mass_preparation');
    });

    test('selects Friday sacrifice action', () async {
      await _insertCalendarDay(db, '2026-06-05', season: 'ordinary');
      await _insertRule(
        db,
        id: 'friday_small_sacrifice_vi',
        priority: 30,
        when: {'weekday': 'friday', 'is_sunday': false},
        action: {
          'type': 'sacrifice',
          'prompt': 'Chọn một điều nhỏ để tiết chế hôm nay.',
        },
      );

      final action = await engine.getOrCreateActionForDate('2026-06-05');

      expect(action.sourceRule, 'friday_small_sacrifice_vi');
      expect(action.prompt, 'Chọn một điều nhỏ để tiết chế hôm nay.');
    });

    test('selects solemnity action before Sunday action', () async {
      await _insertCalendarDay(db, '2026-05-10', season: 'easter');
      await _insertCelebration(db, '2026-05-10', rank: 'solemnity');
      await _insertRule(
        db,
        id: 'solemnity_collect_intention_vi',
        priority: 10,
        when: {'is_solemnity': true},
        action: {
          'type': 'solemnity',
          'prompt': 'Dâng ngày hôm nay trong một ý nguyện rõ ràng.',
        },
      );
      await _insertRule(
        db,
        id: 'sunday_mass_intention_vi',
        priority: 20,
        when: {'weekday': 'sunday', 'is_sunday': true},
        action: {
          'type': 'mass_preparation',
          'prompt': 'Chuẩn bị một ý nguyện trước Thánh lễ.',
        },
      );

      final action = await engine.getOrCreateActionForDate('2026-05-10');

      expect(action.sourceRule, 'solemnity_collect_intention_vi');
      expect(action.type, 'solemnity');
    });

    test('selects seasonal action before default weekday action', () async {
      await _insertCalendarDay(db, '2026-04-28', season: 'easter');
      await _insertRule(
        db,
        id: 'easter_weekday_gospel_note_vi',
        priority: 50,
        when: {'season': 'easter', 'is_sunday': false},
        action: {
          'type': 'reflection',
          'prompt': 'Viết một câu về Tin Mừng hôm nay.',
        },
      );
      await _insertRule(
        db,
        id: 'default_weekday_prayer_vi',
        priority: 100,
        when: {'is_sunday': false, 'is_solemnity': false},
        action: {'type': 'prayer', 'prompt': 'Dành năm phút cầu nguyện.'},
      );

      final action = await engine.getOrCreateActionForDate('2026-04-28');

      expect(action.sourceRule, 'easter_weekday_gospel_note_vi');
      expect(action.type, 'reflection');
    });

    test('selects seasonal action before generic Friday action', () async {
      await _insertCalendarDay(db, '2026-05-01', season: 'easter');
      await _insertRule(
        db,
        id: 'friday_small_sacrifice_vi',
        priority: 30,
        when: {'weekday': 'friday', 'is_sunday': false},
        action: {
          'type': 'sacrifice',
          'prompt': 'Chọn một điều nhỏ để tiết chế hôm nay.',
        },
      );
      await _insertRule(
        db,
        id: 'easter_weekday_gospel_note_vi',
        priority: 50,
        when: {'season': 'easter', 'is_sunday': false},
        action: {
          'type': 'reflection',
          'prompt': 'Viết một câu về Tin Mừng hôm nay.',
        },
      );

      final action = await engine.getOrCreateActionForDate('2026-05-01');

      expect(action.sourceRule, 'easter_weekday_gospel_note_vi');
      expect(action.type, 'reflection');
    });

    test(
      'selects default weekday action when no specific rule matches',
      () async {
        await _insertCalendarDay(db, '2026-06-02', season: 'ordinary');
        await _insertRule(
          db,
          id: 'default_weekday_prayer_vi',
          priority: 100,
          when: {'is_sunday': false, 'is_solemnity': false},
          action: {'type': 'prayer', 'prompt': 'Dành năm phút cầu nguyện.'},
        );

        final action = await engine.getOrCreateActionForDate('2026-06-02');

        expect(action.sourceRule, 'default_weekday_prayer_vi');
        expect(action.priority, 100);
      },
    );

    test('persists generated action for repeatable offline reads', () async {
      await _insertCalendarDay(db, '2026-06-03', season: 'ordinary');
      await _insertRule(
        db,
        id: 'default_weekday_prayer_vi',
        priority: 100,
        when: {'is_sunday': false},
        action: {'type': 'prayer', 'prompt': 'Dành năm phút cầu nguyện.'},
      );

      final first = await engine.getOrCreateActionForDate('2026-06-03');
      final second = await engine.getOrCreateActionForDate('2026-06-03');
      final stored = await db.select(db.dailyActions).get();

      expect(second.id, first.id);
      expect(stored, hasLength(1));
      expect(stored.single.sourceRule, 'default_weekday_prayer_vi');
    });

    test('missing calendar data produces a gentle fallback action', () async {
      final action = await engine.getOrCreateActionForDate('2026-07-01');

      expect(action.sourceRule, DailyActionEngine.fallbackSourceRule);
      expect(action.prompt, DailyActionEngine.fallbackPrompt);
      expect(action.type, DailyActionEngine.fallbackType);

      final calendarDay = await (db.select(
        db.calendarDays,
      )..where((t) => t.date.equals('2026-07-01'))).getSingle();
      expect(calendarDay.season, 'unknown');
    });
  });

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
      'ActionLogDao.saveNote persists a private note before completion',
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
                id: 'action-note',
                date: '2026-04-27',
                sourceRule: 'reading',
                prompt: 'Đọc Tin Mừng',
                type: 'reading',
                priority: 1,
                locale: 'vi',
              ),
            );

        await db.actionLogDao.saveNote('action-note', 'Một câu riêng tư');

        final log = await (db.select(
          db.actionLogs,
        )..where((t) => t.actionId.equals('action-note'))).getSingle();

        expect(log.status, 'pending');
        expect(log.note, 'Một câu riêng tư');
        expect(log.completedAt, isNull);
      },
    );

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

  group('WidgetSnapshotService', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('writes compact Today payload from local data', () async {
      await _insertCalendarDay(db, '2026-04-27', season: 'easter');
      await _insertCelebration(db, '2026-04-27', rank: 'solemnity');
      await db
          .into(db.readings)
          .insert(
            ReadingsCompanion.insert(
              id: 'reading-widget-gospel',
              date: '2026-04-27',
              type: 'gospel',
              citation: 'Ga 3,1-8',
              displayLabel: const Value('Tin Mừng'),
              license: 'reference-only',
              locale: 'vi',
            ),
          );
      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'daily_action_2026-04-27_vi',
              date: '2026-04-27',
              sourceRule: 'easter_weekday_gospel_note_vi',
              prompt: 'Viết một câu về Tin Mừng hôm nay.',
              type: 'reflection',
              priority: 50,
              locale: 'vi',
            ),
          );

      final snapshot = await WidgetSnapshotService(
        db,
      ).regenerateForDate('2026-04-27');
      final payload = jsonDecode(snapshot!.payload) as Map<String, Object?>;
      final action = payload['action']! as Map<String, Object?>;
      final context = payload['liturgical_context']! as Map<String, Object?>;
      final readings = payload['readings']! as List<Object?>;

      expect(payload['date'], '2026-04-27');
      expect(payload['schema_version'], 1);
      expect(context['celebration'], 'Lễ thử nghiệm');
      expect(action['prompt'], 'Viết một câu về Tin Mừng hôm nay.');
      expect(action['completed'], isFalse);
      expect(readings, hasLength(1));
      expect(snapshot.generatedAt, isNotNull);
    });

    test(
      'refreshes snapshot completion state after action log changes',
      () async {
        await _insertCalendarDay(db, '2026-04-27', season: 'ordinary');
        await db
            .into(db.dailyActions)
            .insert(
              DailyActionsCompanion.insert(
                id: 'action-widget-complete',
                date: '2026-04-27',
                sourceRule: 'default_weekday_prayer_vi',
                prompt: 'Dành năm phút cầu nguyện.',
                type: 'prayer',
                priority: 100,
                locale: 'vi',
              ),
            );

        await WidgetSnapshotService(db).regenerateForDate('2026-04-27');
        await db.actionLogDao.markCompleted('action-widget-complete');

        final snapshot = await db.todayDao.getWidgetSnapshot('2026-04-27');
        final payload = jsonDecode(snapshot!.payload) as Map<String, Object?>;
        final action = payload['action']! as Map<String, Object?>;

        expect(action['completed'], isTrue);
        expect(action['status'], 'completed');
      },
    );
  });

  group('WidgetSnapshotBridge', () {
    const channel = MethodChannel('test.songdao/widget_snapshot');
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return true;
          });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('writes latest snapshot over the iOS channel', () async {
      const bridge = WidgetSnapshotBridge(channel: channel);

      final result = await bridge.writeLatestSnapshot(
        date: '2026-04-27',
        payload: '{"date":"2026-04-27"}',
      );

      expect(result.wrote, isTrue);
      expect(result.failed, isFalse);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'writeLatestSnapshot');
      expect(calls.single.arguments, {
        'appGroupId': WidgetSnapshotBridge.appGroupId,
        'date': '2026-04-27',
        'payload': '{"date":"2026-04-27"}',
      });
    });

    test('returns failure instead of throwing on channel errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(
              code: 'app_group_unavailable',
              message: 'No App Group',
            );
          });
      const bridge = WidgetSnapshotBridge(channel: channel);

      final result = await bridge.writeLatestSnapshot(
        date: '2026-04-27',
        payload: '{}',
      );

      expect(result.wrote, isFalse);
      expect(result.failed, isTrue);
      expect(result.code, 'app_group_unavailable');
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

    test('repository defaults lunar display to Vietnamese only', () async {
      final repo = UserSettingsRepository(db);

      expect(await repo.locale(), 'vi');
      expect(await repo.showLunarDate(), isTrue);

      await repo.setShowLunarDate(false);
      expect(await repo.showLunarDate(), isFalse);

      await repo.set(UserSettingsKeys.locale, 'en');
      await repo.setShowLunarDate(true);
      expect(await repo.showLunarDate(), isFalse);
    });
  });

  group('MassService', () {
    late AppDatabase db;

    setUp(() => db = _openTestDb());
    tearDown(() => db.close());

    test('returns selected parish Sunday Mass as important Mass', () async {
      await _insertCalendarDay(db, '2026-05-03', season: 'easter');
      await _insertChurch(db, 'church-1');
      await _insertMassTime(
        db,
        id: 'weekday-mass',
        churchId: 'church-1',
        weekday: 'monday',
        context: 'weekday',
        time: '05:30',
        important: false,
      );
      await _insertMassTime(
        db,
        id: 'sunday-mass',
        churchId: 'church-1',
        weekday: 'sunday',
        context: 'sunday',
        time: '07:30',
        important: true,
      );
      await UserSettingsRepository(db).setSelectedChurchId('church-1');

      final mass = await MassService(db).nextImportantMassForDate('2026-05-03');

      expect(mass, isNotNull);
      expect(mass!.church.name, 'Giáo xứ thử nghiệm');
      expect(mass.massTime.id, 'sunday-mass');
      expect(mass.label, 'Thánh lễ Chúa nhật');
    });

    test('returns null when no parish is selected', () async {
      await _insertCalendarDay(db, '2026-05-03', season: 'easter');
      await _insertChurch(db, 'church-1');

      final mass = await MassService(db).nextImportantMassForDate('2026-05-03');

      expect(mass, isNull);
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
        expect(await db.select(db.prayers).get(), hasLength(3));
        expect(await db.select(db.churches).get(), hasLength(1));
        expect(await db.select(db.massTimes).get(), hasLength(2));

        final readings = await db.select(db.readings).get();
        expect(
          readings.every((reading) => reading.textContent == null),
          isTrue,
        );
        final calendarDay = await (db.select(
          db.calendarDays,
        )..where((t) => t.date.equals('2026-04-28'))).getSingle();
        expect(calendarDay.lunarDate, '12 tháng 3, Bính Ngọ');

        final manifest =
            await (db.select(db.userSettings)
                  ..where((t) => t.key.equals('active_content_pack_manifest')))
                .getSingle();
        expect(manifest.value, contains('calendar-vn-demo-2026'));
      },
    );
  });
}

Future<void> _insertCalendarDay(
  AppDatabase db,
  String date, {
  required String season,
}) {
  return db
      .into(db.calendarDays)
      .insert(
        CalendarDaysCompanion.insert(
          date: date,
          season: season,
          liturgicalWeek: 1,
          color: 'green',
          cycleYear: 'C',
          locale: 'vi',
        ),
      );
}

Future<void> _insertCelebration(
  AppDatabase db,
  String date, {
  required String rank,
}) {
  return db
      .into(db.celebrations)
      .insert(
        CelebrationsCompanion.insert(
          id: 'celebration-$date-$rank',
          date: date,
          name: 'Lễ thử nghiệm',
          rank: rank,
          locale: 'vi',
        ),
      );
}

Future<void> _insertChurch(AppDatabase db, String id) {
  return db
      .into(db.churches)
      .insert(
        ChurchesCompanion.insert(
          id: id,
          locale: 'vi',
          name: 'Giáo xứ thử nghiệm',
          diocese: 'Giáo phận thử nghiệm',
          address: '123 Đường thử nghiệm',
          source: '{}',
        ),
      );
}

Future<void> _insertMassTime(
  AppDatabase db, {
  required String id,
  required String churchId,
  required String weekday,
  required String context,
  required String time,
  required bool important,
}) {
  return db
      .into(db.massTimes)
      .insert(
        MassTimesCompanion.insert(
          id: id,
          churchId: churchId,
          weekday: weekday,
          context: context,
          time: time,
          language: 'vi',
          validFrom: DateTime(2026, 4, 27),
          isImportantDefault: Value(important),
          source: '{}',
        ),
      );
}

Future<void> _insertRule(
  AppDatabase db, {
  required String id,
  required int priority,
  required Map<String, Object?> when,
  required Map<String, Object?> action,
}) {
  return db
      .into(db.actionRules)
      .insert(
        ActionRulesCompanion.insert(
          id: id,
          type: action['type']! as String,
          triggerCondition: jsonEncode(when),
          templatePrompt: jsonEncode(action),
          priority: priority,
          locale: const Value('vi'),
        ),
      );
}
