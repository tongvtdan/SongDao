import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/content/content_pack_importer.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/app_icon_service.dart';
import 'package:songdao/data/local/daily_action_engine.dart';
import 'package:songdao/data/local/mass_service.dart';
import 'package:songdao/data/local/user_settings_repository.dart';
import 'package:songdao/data/local/widget_snapshot_bridge.dart';
import 'package:songdao/data/local/widget_snapshot_service.dart';
import 'package:songdao/features/today/today_controller.dart';
import 'package:songdao/notifications/local_notification_service.dart';

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

    test('selects feast action before seasonal action', () async {
      await _insertCalendarDay(db, '2026-05-14', season: 'easter');
      await _insertCelebration(db, '2026-05-14', rank: 'feast');
      await _insertRule(
        db,
        id: 'feast_witness_vi',
        priority: 15,
        when: {'is_feast': true},
        action: {
          'type': 'reflection',
          'prompt': 'Chọn một cách nhỏ để làm chứng cho đức tin hôm nay.',
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

      final action = await engine.getOrCreateActionForDate('2026-05-14');

      expect(action.sourceRule, 'feast_witness_vi');
      expect(
        action.prompt,
        'Chọn một cách nhỏ để làm chứng cho đức tin hôm nay.',
      );
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

    test(
      'replaces fallback action after real calendar content arrives',
      () async {
        final fallback = await engine.getOrCreateActionForDate('2026-05-14');
        expect(fallback.sourceRule, DailyActionEngine.fallbackSourceRule);

        await (db.update(
          db.calendarDays,
        )..where((t) => t.date.equals('2026-05-14'))).write(
          const CalendarDaysCompanion(
            season: Value('easter'),
            liturgicalWeek: Value(6),
            color: Value('red'),
            cycleYear: Value('A'),
          ),
        );
        await _insertCelebration(db, '2026-05-14', rank: 'feast');
        await _insertRule(
          db,
          id: 'feast_witness_vi',
          priority: 15,
          when: {'is_feast': true},
          action: {
            'type': 'reflection',
            'prompt': 'Chọn một cách nhỏ để làm chứng cho đức tin hôm nay.',
          },
        );

        final refreshed = await engine.getOrCreateActionForDate('2026-05-14');

        expect(refreshed.id, fallback.id);
        expect(refreshed.sourceRule, 'feast_witness_vi');
      },
    );
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

    test(
      'ActionLogDao.getJournalEntries lists non-empty notes newest first',
      () async {
        await _insertCalendarDay(db, '2026-04-27', season: 'ordinary');
        await _insertCalendarDay(db, '2026-04-28', season: 'ordinary');
        await _insertDailyAction(
          db,
          id: 'journal-action-1',
          date: '2026-04-27',
          prompt: 'Đọc Tin Mừng',
        );
        await _insertDailyAction(
          db,
          id: 'journal-action-2',
          date: '2026-04-28',
          prompt: 'Cầu nguyện',
        );
        await _insertDailyAction(
          db,
          id: 'journal-action-empty',
          date: '2026-04-28',
          prompt: 'Ghi chú trống',
        );

        await db.actionLogDao.saveNote('journal-action-1', 'Một câu riêng tư');
        await db.actionLogDao.saveNote('journal-action-2', 'Lời cầu hôm nay');
        await db.actionLogDao.saveNote('journal-action-empty', '   ');

        final entries = await db.actionLogDao.getJournalEntries();

        expect(entries, hasLength(2));
        expect(entries.first.action.id, 'journal-action-2');
        expect(entries.first.note, 'Lời cầu hôm nay');
        expect(entries.last.action.id, 'journal-action-1');
      },
    );

    test('ActionLogDao.getJournalEntries searches note and prompt', () async {
      await _insertCalendarDay(db, '2026-04-27', season: 'ordinary');
      await _insertCalendarDay(db, '2026-04-28', season: 'ordinary');
      await _insertDailyAction(
        db,
        id: 'journal-search-1',
        date: '2026-04-27',
        prompt: 'Đọc Tin Mừng',
      );
      await _insertDailyAction(
        db,
        id: 'journal-search-2',
        date: '2026-04-28',
        prompt: 'Dâng một lời cầu',
      );

      await db.actionLogDao.saveNote('journal-search-1', 'Bình an trong ngày');
      await db.actionLogDao.saveNote('journal-search-2', 'Tạ ơn buổi sáng');

      final byNote = await db.actionLogDao.getJournalEntries(query: 'bình an');
      final byPrompt = await db.actionLogDao.getJournalEntries(
        query: 'lời cầu',
      );

      expect(byNote.single.action.id, 'journal-search-1');
      expect(byPrompt.single.action.id, 'journal-search-2');
    });

    test(
      'ActionLogDao.saveNote edits and clearNote removes journal note',
      () async {
        await _insertCalendarDay(db, '2026-04-27', season: 'ordinary');
        await _insertDailyAction(
          db,
          id: 'journal-edit',
          date: '2026-04-27',
          prompt: 'Viết một câu',
        );

        await db.actionLogDao.saveNote('journal-edit', 'Bản đầu');
        await db.actionLogDao.saveNote('journal-edit', 'Bản sửa');

        var entries = await db.actionLogDao.getJournalEntries();
        expect(entries.single.note, 'Bản sửa');

        await db.actionLogDao.clearNote('journal-edit');
        entries = await db.actionLogDao.getJournalEntries();
        final log = await (db.select(
          db.actionLogs,
        )..where((t) => t.actionId.equals('journal-edit'))).getSingle();

        expect(entries, isEmpty);
        expect(log.note, isNull);
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
      final dailyQuote = payload['daily_quote']! as Map<String, Object?>;
      final readings = payload['readings']! as List<Object?>;

      expect(payload['date'], '2026-04-27');
      expect(payload['schema_version'], 1);
      expect(context['celebration'], 'Lễ thử nghiệm');
      expect(dailyQuote['text'], isNotEmpty);
      expect(dailyQuote['attribution'], 'Lời gợi hứng hôm nay');
      expect(payload['saint_of_day'], isNull);
      expect(action['prompt'], 'Viết một câu về Tin Mừng hôm nay.');
      expect(action['completed'], isFalse);
      expect(readings, hasLength(1));
      expect(snapshot.generatedAt, isNotNull);
    });

    test(
      'adds saint of day when the local calendar has a saint feast',
      () async {
        await _insertCalendarDay(db, '2026-04-28', season: 'easter');
        await _insertCelebration(
          db,
          '2026-04-28',
          rank: 'feast',
          name: 'Thánh Phêrô Chanel',
        );
        await db
            .into(db.dailyActions)
            .insert(
              DailyActionsCompanion.insert(
                id: 'daily_action_2026-04-28_vi',
                date: '2026-04-28',
                sourceRule: 'saint_feast_vi',
                prompt: 'Cầu nguyện với vị thánh hôm nay.',
                type: 'prayer',
                priority: 40,
                locale: 'vi',
              ),
            );

        final snapshot = await WidgetSnapshotService(
          db,
        ).regenerateForDate('2026-04-28');
        final payload = jsonDecode(snapshot!.payload) as Map<String, Object?>;

        expect(payload['saint_of_day'], 'Thánh Phêrô Chanel');
      },
    );

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

  group('AppIconService', () {
    const channel = MethodChannel('test.songdao/icon');
    late AppDatabase db;
    late List<MethodCall> calls;

    setUp(() {
      db = _openTestDb();
      calls = [];
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'supportsAlternateIcons') {
              return true;
            }
            return null;
          });
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await db.close();
    });

    test('maps liturgical context to predefined icon variants', () {
      expect(recommendedIconVariant(season: 'advent'), AppIconVariant.advent);
      expect(recommendedIconVariant(season: 'lent'), AppIconVariant.lent);
      expect(
        recommendedIconVariant(
          season: 'ordinary',
          celebrations: ['Đức Mẹ Mân Côi'],
        ),
        AppIconVariant.marian,
      );
      expect(recommendedIconVariant(season: 'unknown'), AppIconVariant.primary);
    });

    test('sets supported iOS alternate icon and persists variant', () async {
      final service = AppIconService(
        db: db,
        settings: UserSettingsRepository(db),
        channel: channel,
      );

      final wrote = await service.setIcon(AppIconVariant.easter);

      expect(wrote, isTrue);
      expect(calls.single.method, 'setIcon');
      expect(calls.single.arguments, {'iconName': 'easter'});
      expect(
        await UserSettingsRepository(db).selectedAppIconVariant(),
        'easter',
      );
    });

    test('does not apply seasonal icon when setting is disabled', () async {
      await _insertCalendarDay(db, '2026-12-25', season: 'christmas');
      final service = AppIconService(
        db: db,
        settings: UserSettingsRepository(db),
        channel: channel,
      );

      final wrote = await service.applySeasonalIconForDate('2026-12-25');

      expect(wrote, isFalse);
      expect(calls, isEmpty);
    });

    test('applies recommended icon when seasonal setting is enabled', () async {
      await _insertCalendarDay(db, '2026-12-25', season: 'christmas');
      await UserSettingsRepository(db).setSeasonalIconEnabled(true);
      final service = AppIconService(
        db: db,
        settings: UserSettingsRepository(db),
        channel: channel,
      );

      final wrote = await service.applySeasonalIconForDate('2026-12-25');

      expect(wrote, isTrue);
      expect(calls.map((call) => call.method), [
        'supportsAlternateIcons',
        'setIcon',
      ]);
      expect(calls.last.arguments, {'iconName': 'christmas'});
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

    test('repository stores daily reminder settings locally', () async {
      final repo = UserSettingsRepository(db);

      var reminder = await repo.dailyReminder();
      expect(reminder.enabled, isFalse);
      expect(reminder.hour, 7);
      expect(reminder.minute, 0);

      await repo.setDailyReminderTime(hour: 20, minute: 30);
      await repo.setDailyReminderEnabled(true);

      reminder = await repo.dailyReminder();
      expect(reminder.enabled, isTrue);
      expect(reminder.hour, 20);
      expect(reminder.minute, 30);
    });

    test('repository ignores invalid daily reminder time values', () async {
      final repo = UserSettingsRepository(db);

      await repo.set(UserSettingsKeys.dailyReminderHour, '99');
      await repo.set(UserSettingsKeys.dailyReminderMinute, 'bad');

      final reminder = await repo.dailyReminder();
      expect(reminder.hour, 7);
      expect(reminder.minute, 0);
    });
  });

  group('NotificationRoutes', () {
    test('maps notification payloads to Today route', () {
      expect(NotificationRoutes.routeFromPayload(null), '/today');
      expect(NotificationRoutes.routeFromPayload(''), '/today');
      expect(
        NotificationRoutes.routeFromPayload(NotificationRoutes.todayUri),
        '/today',
      );
      expect(NotificationRoutes.routeFromPayload('/today'), '/today');
      expect(NotificationRoutes.routeFromPayload('not a route'), '/today');
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

    test('returns weekday Mass on a Monday when no special day', () async {
      // 2026-04-27 is a Monday, ordinary season
      await _insertCalendarDay(db, '2026-04-27', season: 'ordinary');
      await _insertChurch(db, 'church-1');
      await _insertMassTime(
        db,
        id: 'weekday-monday-0530',
        churchId: 'church-1',
        weekday: 'monday',
        context: 'weekday',
        time: '05:30',
        important: true,
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

      final mass = await MassService(db).nextImportantMassForDate('2026-04-27');

      expect(mass, isNotNull);
      expect(mass!.massTime.id, 'weekday-monday-0530');
    });

    test('returns solemnity Mass on a solemnity day', () async {
      // 2026-06-11 is a Thursday in ordinary time, but we mark it as solemnity
      await _insertCalendarDay(db, '2026-06-11', season: 'ordinary');
      await _insertCelebration(db, '2026-06-11', rank: 'solemnity');
      await _insertChurch(db, 'church-1');
      await _insertMassTime(
        db,
        id: 'weekday-mass',
        churchId: 'church-1',
        weekday: 'thursday',
        context: 'weekday',
        time: '05:30',
        important: false,
      );
      await _insertMassTime(
        db,
        id: 'solemnity-mass',
        churchId: 'church-1',
        weekday: 'thursday',
        context: 'solemnity',
        time: '18:00',
        important: true,
      );
      await UserSettingsRepository(db).setSelectedChurchId('church-1');

      final mass = await MassService(db).nextImportantMassForDate('2026-06-11');

      expect(mass, isNotNull);
      expect(mass!.massTime.id, 'solemnity-mass');
      expect(mass.label, 'Thánh lễ trọng');
    });

    test('returns null when church has no Mass times', () async {
      await _insertCalendarDay(db, '2026-05-03', season: 'easter');
      await _insertChurch(db, 'church-1');
      await UserSettingsRepository(db).setSelectedChurchId('church-1');

      final mass = await MassService(db).nextImportantMassForDate('2026-05-03');

      expect(mass, isNull);
    });

    test('returns null when only Mass time is expired', () async {
      await _insertCalendarDay(db, '2026-05-03', season: 'easter');
      await _insertChurch(db, 'church-1');
      await _insertMassTime(
        db,
        id: 'expired-sunday-mass',
        churchId: 'church-1',
        weekday: 'sunday',
        context: 'sunday',
        time: '07:30',
        important: true,
        validTo: DateTime(2025, 12, 31),
      );
      await UserSettingsRepository(db).setSelectedChurchId('church-1');

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
        expect(await db.select(db.churches).get(), isEmpty);
        expect(await db.select(db.massTimes).get(), isEmpty);

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

    test(
      'imports calendar pack and generates daily action timeline and widget snapshots validating schema',
      () async {
        final source = await File(
          '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
        ).readAsString();
        final importer = ContentPackImporter(db);

        final result = await importer.importPackJson(source);
        expect(result.imported, isTrue);

        // Verify that 14 days of widget snapshots are generated in the database
        final snapshots = await db.select(db.widgetSnapshots).get();
        expect(snapshots, hasLength(14));

        // Decode and validate the snapshot payloads conform to Drift widget snapshot schema
        for (final snapshot in snapshots) {
          expect(snapshot.date, isNotNull);
          expect(snapshot.payload, isNotNull);
          expect(snapshot.generatedAt, isNotNull);

          final payload = jsonDecode(snapshot.payload) as Map<String, Object?>;
          expect(payload['schema_version'], equals(1));
          expect(payload['date'], equals(snapshot.date));
          expect(payload['locale'], equals('vi'));
          expect(payload['generated_at'], isNotNull);

          final context =
              payload['liturgical_context']! as Map<String, Object?>;
          expect(context['season'], isNotNull);
          expect(context['color'], isNotNull);
          expect(context['liturgical_week'], isNotNull);
          expect(context.containsKey('cycle_year'), isTrue);
          expect(context['lunar_date'], isNotNull);

          final action = payload['action']! as Map<String, Object?>;
          expect(action['id'], isNotNull);
          expect(action['type'], isNotNull);
          expect(action['prompt'], isNotNull);
          expect(action['completed'], isFalse);
          expect(action['status'], equals('pending'));

          final readings = payload['readings']! as List<Object?>;
          expect(readings, isNotEmpty);
          for (final readingObj in readings) {
            final reading = readingObj as Map<String, Object?>;
            expect(reading['type'], isNotNull);
            expect(reading['label'], isNotNull);
            expect(reading['citation'], isNotNull);
          }
        }
      },
    );

    test(
      'imports the parish beta seed pack with 3 churches and varied Mass times',
      () async {
        final source = await File(
          '../content/packs/songdao-pack-parishes-vn-beta-2026-0.1.0.json',
        ).readAsString();
        final importer = ContentPackImporter(db);

        final result = await importer.importPackJson(source);

        expect(result.packId, 'parishes-vn-beta-2026');
        expect(result.imported, isTrue);
        expect(
          (await db.select(db.churches).get()).length,
          greaterThanOrEqualTo(3),
        );

        final massTimes = await db.select(db.massTimes).get();
        // At least Sunday, weekday, and vigil entries
        expect(massTimes.length, greaterThanOrEqualTo(10));
        expect(massTimes.any((m) => m.context == 'sunday'), isTrue);
        expect(massTimes.any((m) => m.context == 'weekday'), isTrue);
        expect(massTimes.any((m) => m.context == 'saturday_vigil'), isTrue);
        // Stale entry (valid_to in 2025) is imported but can be filtered
        expect(massTimes.any((m) => m.validTo != null), isTrue);
        // Bilingual: at least one English Mass
        expect(massTimes.any((m) => m.language == 'en'), isTrue);
      },
    );

    test(
      'imports post-demo pack and keeps Today useful after demo horizon',
      () async {
        final importer = ContentPackImporter(db);
        final demoSource = await File(
          '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
        ).readAsString();
        final postDemoSource = await File(
          '../content/packs/songdao-pack-calendar-vn-post-demo-2026-0.1.0.json',
        ).readAsString();

        await importer.importPackJson(demoSource);
        final result = await importer.importPackJson(postDemoSource);

        expect(result.packId, 'calendar-vn-post-demo-2026');

        final controller = TodayController(
          db: db,
          settings: UserSettingsRepository(db),
          engine: DailyActionEngine(db),
        );
        final data = await controller.load(date: '2026-05-14');

        expect(data.calendarDay.season, 'easter');
        expect(data.celebrations.single.name, 'Thánh Matthia, Tông đồ');
        expect(
          data.readings.any((reading) => reading.type == 'gospel'),
          isTrue,
        );
        expect(
          data.readings.every((reading) => reading.textContent == null),
          isTrue,
        );
        expect(data.action.sourceRule, 'feast_witness_vi');

        await controller.completeAction(data, note: 'Một việc nhỏ đã làm.');
        final snapshot = await db.todayDao.getWidgetSnapshot('2026-05-14');
        final payload = jsonDecode(snapshot!.payload) as Map<String, Object?>;
        final action = payload['action']! as Map<String, Object?>;
        expect(action['completed'], isTrue);
      },
    );

    test('imports full 2026 Vietnam calendar pack with safe content', () async {
      final source = await File(
        '../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json',
      ).readAsString();
      final importer = ContentPackImporter(db);

      final result = await importer.importPackJson(source);

      expect(result.packId, 'calendar-vn-2026');
      expect(await db.select(db.calendarDays).get(), hasLength(365));
      expect((await db.select(db.celebrations).get()).length, greaterThan(365));
      final readings = await db.select(db.readings).get();
      expect(readings.length, greaterThan(365));
      expect(readings.map((reading) => reading.date).toSet(), hasLength(365));
      expect(await db.select(db.dailyReflections).get(), hasLength(365));

      for (final date in ['2026-01-01', '2026-05-14', '2026-12-31']) {
        final day =
            await (db.select(db.calendarDays)
                  ..where((t) => t.date.equals(date) & t.locale.equals('vi')))
                .getSingle();
        expect(day.season, isNot('unknown'));
        expect(day.lunarDate, isNotNull);
        expect(
          await (db.select(db.dailyReflections)
                ..where((t) => t.date.equals(date) & t.locale.equals('vi')))
              .getSingleOrNull(),
          isNotNull,
        );
      }

      final unsafeReadings =
          await (db.select(db.readings)..where(
                (t) =>
                    t.license.equals('reference-only') &
                    t.textContent.isNotNull(),
              ))
              .get();
      expect(unsafeReadings, isEmpty);

      final may19Readings =
          await (db.select(db.readings)..where(
                (t) => t.date.equals('2026-05-19') & t.locale.equals('vi'),
              ))
              .get();
      expect(
        may19Readings.map((reading) => reading.citation),
        containsAll(['Cv 20,17-27', 'Tv 68,10-11.20-21', 'Ga 17,1-11a']),
      );
    });

    test('Today loads real 2026 calendar data and reflection', () async {
      final importer = ContentPackImporter(db);
      final source = await File(
        '../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json',
      ).readAsString();
      await importer.importPackJson(source);

      final controller = TodayController(
        db: db,
        settings: UserSettingsRepository(db),
        engine: DailyActionEngine(db),
      );
      final data = await controller.load(date: '2026-06-15');

      expect(data.calendarDay.season, isNot('unknown'));
      expect(data.readings, isNotEmpty);
      expect(data.reflection, isNotNull);
      expect(
        data.action.sourceRule,
        isNot(DailyActionEngine.fallbackSourceRule),
      );
    });

    test(
      'default bundled packs include calendar 2026 and parish data',
      () async {
        expect(defaultContentPackAssets, hasLength(2));
        expect(
          defaultContentPackAssets.any((asset) => asset.contains('demo')),
          isFalse,
        );

        final importer = ContentPackImporter(db);

        for (final asset in defaultContentPackAssets) {
          final filePath = asset.replaceFirst('../', '../');
          await importer.importPackJson(await File(filePath).readAsString());
        }

        final juneDay =
            await (db.select(db.calendarDays)..where(
                  (t) => t.date.equals('2026-06-15') & t.locale.equals('vi'),
                ))
                .getSingleOrNull();
        expect(juneDay, isNotNull);
        expect(
          (await db.select(db.churches).get()).length,
          greaterThanOrEqualTo(3),
        );
        expect(
          (await db.select(db.massTimes).get()).length,
          greaterThanOrEqualTo(10),
        );
        final calendarDays = await db.select(db.calendarDays).get();
        expect(
          calendarDays.map((day) => '${day.locale}:${day.date}').toSet(),
          hasLength(calendarDays.length),
        );
      },
    );

    test(
      'overlapping calendar packs use the most recently imported readings',
      () async {
        final importer = ContentPackImporter(db);
        final fullSource = await File(
          '../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json',
        ).readAsString();
        final demoSource = await File(
          '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
        ).readAsString();

        await importer.importPackJson(fullSource);
        await importer.importPackJson(demoSource);

        const overlapDate = '2026-04-28';
        final demoPack = jsonDecode(demoSource) as Map<String, Object?>;
        final expectedDemoCitations = _citationsForDate(demoPack, overlapDate);
        final demoReadings =
            await (db.select(db.readings)..where(
                  (t) => t.date.equals(overlapDate) & t.locale.equals('vi'),
                ))
                .get();

        expect(
          demoReadings.map((reading) => reading.citation).toSet(),
          expectedDemoCitations,
        );
        expect(demoReadings, hasLength(expectedDemoCitations.length));
        expect(
          await (db.select(db.calendarDays)..where(
                (t) => t.date.equals(overlapDate) & t.locale.equals('vi'),
              ))
              .get(),
          hasLength(1),
        );
        final demoRuleIds = _idsFromPack(demoPack, 'action_rules');
        final demoAction = await DailyActionEngine(
          db,
        ).getOrCreateActionForDate(overlapDate);
        expect(demoRuleIds, contains(demoAction.sourceRule));

        final restored = await importer.importPackJson(fullSource);
        final fullPack = jsonDecode(fullSource) as Map<String, Object?>;
        final expectedFullCitations = _citationsForDate(fullPack, overlapDate);
        final fullReadings =
            await (db.select(db.readings)..where(
                  (t) => t.date.equals(overlapDate) & t.locale.equals('vi'),
                ))
                .get();

        expect(restored.imported, isTrue);
        expect(
          fullReadings.map((reading) => reading.citation).toSet(),
          expectedFullCitations,
        );
        expect(fullReadings, hasLength(expectedFullCitations.length));
        final fullRuleIds = _idsFromPack(fullPack, 'action_rules');
        final fullAction = await DailyActionEngine(
          db,
        ).getOrCreateActionForDate(overlapDate);
        expect(fullRuleIds, contains(fullAction.sourceRule));
      },
    );

    test(
      'new pack version removes stale rows and preserves completion notes',
      () async {
        final source = await File(
          '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
        ).readAsString();
        final pack = jsonDecode(source) as Map<String, Object?>;
        final celebrations = pack['celebrations']! as List<Object?>;
        final readings = pack['readings']! as List<Object?>;
        final actionRules = pack['action_rules']! as List<Object?>;
        final staleCelebration =
            celebrations.removeAt(0)! as Map<String, Object?>;
        final staleReading = readings.removeAt(0)! as Map<String, Object?>;
        final staleRule = actionRules.removeAt(0)! as Map<String, Object?>;
        pack['version'] = '0.1.1';
        final updatedSource = _encodePackWithChecksum(pack);
        final importer = ContentPackImporter(db);

        await importer.importPackJson(source);
        final controller = TodayController(
          db: db,
          settings: UserSettingsRepository(db),
          engine: DailyActionEngine(db),
        );
        final today = await controller.load(date: '2026-04-28');
        await controller.completeAction(
          today,
          note: 'Ghi chú riêng phải được giữ lại.',
        );

        await importer.importPackJson(updatedSource);

        expect(
          await (db.select(db.celebrations)
                ..where((t) => t.id.equals(staleCelebration['id']! as String)))
              .getSingleOrNull(),
          isNull,
        );
        expect(
          await (db.select(db.readings)
                ..where((t) => t.id.equals(staleReading['id']! as String)))
              .getSingleOrNull(),
          isNull,
        );
        expect(
          await (db.select(db.actionRules)
                ..where((t) => t.id.equals(staleRule['id']! as String)))
              .getSingleOrNull(),
          isNull,
        );

        final preservedLog = await db.todayDao.getActionLogForAction(
          today.action.id,
        );
        expect(preservedLog?.status, 'completed');
        expect(preservedLog?.note, 'Ghi chú riêng phải được giữ lại.');
      },
    );
  });
}

Set<String> _citationsForDate(Map<String, Object?> pack, String date) {
  return (pack['readings']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .where((reading) => reading['date'] == date)
      .map((reading) => reading['citation']! as String)
      .toSet();
}

Set<String> _idsFromPack(Map<String, Object?> pack, String field) {
  return (pack[field]! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map((row) => row['id']! as String)
      .toSet();
}

String _encodePackWithChecksum(Map<String, Object?> pack) {
  pack['checksum'] = '';
  final canonical = jsonEncode(_canonicalJsonValue(pack));
  pack['checksum'] = 'sha256:${sha256.convert(utf8.encode(canonical))}';
  return jsonEncode(pack);
}

Object? _canonicalJsonValue(Object? value) {
  if (value is Map) {
    final sorted = <String, Object?>{};
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    for (final key in keys) {
      sorted[key] = _canonicalJsonValue(value[key]);
    }
    return sorted;
  }
  if (value is List) {
    return value.map(_canonicalJsonValue).toList(growable: false);
  }
  return value;
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

Future<void> _insertDailyAction(
  AppDatabase db, {
  required String id,
  required String date,
  required String prompt,
}) {
  return db
      .into(db.dailyActions)
      .insert(
        DailyActionsCompanion.insert(
          id: id,
          date: date,
          sourceRule: 'test_rule',
          prompt: prompt,
          type: 'reflection',
          priority: 1,
          locale: 'vi',
        ),
      );
}

Future<void> _insertCelebration(
  AppDatabase db,
  String date, {
  required String rank,
  String name = 'Lễ thử nghiệm',
}) {
  return db
      .into(db.celebrations)
      .insert(
        CelebrationsCompanion.insert(
          id: 'celebration-$date-$rank',
          date: date,
          name: name,
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
  DateTime? validTo,
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
          validTo: Value(validTo),
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
