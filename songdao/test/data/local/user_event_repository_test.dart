import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_importer.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/user_event_repository.dart';
import 'package:songdao/data/local/vietnamese_lunar_calendar_service.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('UserEventRepository', () {
    late AppDatabase db;
    late UserEventRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = UserEventRepository(
        db,
        const VietnameseLunarCalendarService(),
      );
    });

    tearDown(() => db.close());

    test('creates, updates, reads and deletes a private event', () async {
      final id = await repository.create(
        _draft(title: 'Ngày giỗ ông ngoại', note: 'Thắp hương buổi tối'),
      );

      final created = await repository.getById(id);
      expect(created, isNotNull);
      expect(created!.title, 'Ngày giỗ ông ngoại');
      expect(created.note, 'Thắp hương buổi tối');

      await repository.updateEvent(
        id,
        _draft(title: 'Ngày giỗ ông', note: '  '),
      );
      final updated = await repository.getById(id);
      expect(updated!.title, 'Ngày giỗ ông');
      expect(updated.note, isNull);

      await repository.deleteEvent(id);
      expect(await repository.getById(id), isNull);
    });

    test('returns every event occurring on the same date', () async {
      await repository.create(_draft(title: 'Sự kiện A'));
      await repository.create(_draft(title: 'Sự kiện B'));

      final occurrences = await repository.occurrencesOn(DateTime(2026, 8, 9));

      expect(occurrences, hasLength(2));
      expect(occurrences.map((occurrence) => occurrence.event.title), [
        'Sự kiện A',
        'Sự kiện B',
      ]);
    });

    test('supports timed events, colors and minute reminders', () async {
      final id = await repository.create(
        _draft(
          title: 'Kinh tối',
          recurrence: EventRecurrence.weekly,
          eventHour: 19,
          eventMinute: 30,
          color: UserEventColor.purple,
          reminderOffsetMinutes: 15,
        ),
      );

      final event = await repository.getById(id);
      expect(event!.eventHour, 19);
      expect(event.eventMinute, 30);
      expect(event.color, UserEventColor.purple.storageValue);
      expect(event.reminderOffsetMinutes, 15);
      expect(event.reminderOffsetDays, isNull);
    });

    test('computes daily, weekly and monthly solar occurrences', () async {
      final dailyId = await repository.create(
        _draft(
          title: 'Hằng ngày',
          recurrence: EventRecurrence.daily,
          year: 2026,
          month: 8,
          day: 9,
        ),
      );
      final weeklyId = await repository.create(
        _draft(
          title: 'Hằng tuần',
          recurrence: EventRecurrence.weekly,
          year: 2026,
          month: 8,
          day: 10,
        ),
      );
      final monthlyId = await repository.create(
        _draft(
          title: 'Ngày 31',
          recurrence: EventRecurrence.monthly,
          year: 2026,
          month: 1,
          day: 31,
        ),
      );

      final daily = repository.occurrencesForEventBetween(
        (await repository.getById(dailyId))!,
        DateTime(2026, 8, 9),
        DateTime(2026, 8, 11),
      );
      final weekly = repository.occurrencesForEventBetween(
        (await repository.getById(weeklyId))!,
        DateTime(2026, 8, 9),
        DateTime(2026, 8, 24),
      );
      final monthly = repository.occurrencesForEventBetween(
        (await repository.getById(monthlyId))!,
        DateTime(2026, 1, 1),
        DateTime(2026, 3, 31),
      );

      expect(daily.map((item) => item.date), [
        DateTime(2026, 8, 9),
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 11),
      ]);
      expect(weekly.map((item) => item.date), [
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 17),
        DateTime(2026, 8, 24),
      ]);
      expect(monthly.map((item) => item.date), [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
      ]);
    });

    test('computes monthly lunar occurrences and clamps day 30', () async {
      const lunar = VietnameseLunarCalendarService();
      const anchor = LunarDateValue(year: 2026, month: 1, day: 30);
      final id = await repository.create(
        _draft(
          title: 'Ngày 30 âm lịch',
          system: EventCalendarSystem.lunar,
          year: anchor.year,
          month: anchor.month,
          day: anchor.day,
          recurrence: EventRecurrence.monthly,
        ),
      );
      final event = (await repository.getById(id))!;
      final occurrences = repository.occurrencesForEventBetween(
        event,
        lunar.lunarToSolarExact(anchor),
        DateTime(2026, 5, 31),
      );

      expect(occurrences, hasLength(3));
      expect(
        occurrences.map((item) => lunar.solarToLunar(item.date).day),
        everyElement(anyOf(29, 30)),
      );
    });

    test('clamps a recurring February 29 event to February 28', () async {
      final id = await repository.create(
        _draft(
          title: 'Kỷ niệm ngày nhuận',
          year: 2024,
          month: 2,
          day: 29,
          recurrence: EventRecurrence.yearly,
        ),
      );
      final event = (await repository.getById(id))!;

      final occurrences = repository.occurrencesForEventBetween(
        event,
        DateTime(2024, 1, 1),
        DateTime(2026, 12, 31),
      );

      expect(occurrences.map((occurrence) => occurrence.date), [
        DateTime(2024, 2, 29),
        DateTime(2025, 2, 28),
        DateTime(2026, 2, 28),
      ]);
    });

    test(
      'computes lunar occurrences across a Gregorian year boundary',
      () async {
        const lunar = VietnameseLunarCalendarService();
        const anchor = LunarDateValue(year: 2025, month: 12, day: 15);
        final anchorSolar = lunar.lunarToSolarExact(anchor);
        final id = await repository.create(
          _draft(
            title: 'Ngày giỗ âm lịch',
            type: UserEventType.deathAnniversary,
            system: EventCalendarSystem.lunar,
            year: anchor.year,
            month: anchor.month,
            day: anchor.day,
            recurrence: EventRecurrence.yearly,
          ),
        );
        final event = (await repository.getById(id))!;

        final occurrences = repository.occurrencesForEventBetween(
          event,
          DateTime(2026, 1, 1),
          DateTime(2027, 1, 31),
        );

        expect(occurrences.first.date, anchorSolar);
        expect(occurrences, hasLength(2));
        expect(
          lunar.solarToLunar(occurrences.last.date),
          const LunarDateValue(year: 2026, month: 12, day: 15),
        );
      },
    );

    test('content-pack reimport never overwrites user events', () async {
      final id = await repository.create(_draft(title: 'Sự kiện riêng'));
      final source = await File(
        '../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json',
      ).readAsString();
      final importer = ContentPackImporter(db);

      await importer.importPackJson(source);
      await importer.importPackJson(source);

      expect((await repository.getById(id))!.title, 'Sự kiện riêng');
      expect(await repository.getAll(), hasLength(1));
    });

    test('validates text, date and complete reminder fields', () async {
      expect(
        () => repository.create(_draft(title: '   ')),
        throwsA(isA<UserEventValidationException>()),
      );
      expect(
        () => repository.create(
          _draft(title: 'Sai ngày', year: 2026, month: 2, day: 30),
        ),
        throwsA(isA<UserEventValidationException>()),
      );
      expect(
        () => repository.create(
          _draft(title: 'Thiếu giờ', reminderOffsetDays: 1),
        ),
        throwsA(isA<UserEventValidationException>()),
      );
    });
  });

  test('migrates a version 7 database by creating user_events', () async {
    final directory = await Directory.systemTemp.createTemp('songdao-v7-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/songdao.sqlite');
    final legacy = sqlite3.open(file.path);
    legacy.execute('PRAGMA user_version = 7');
    legacy.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    expect(db.schemaVersion, 9);
    expect(await db.select(db.userEvents).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 9);
  });

  test('migrates version 8 event reminders and defaults color', () async {
    final directory = await Directory.systemTemp.createTemp('songdao-v8-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/songdao.sqlite');
    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE user_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        note TEXT,
        calendar_system TEXT NOT NULL,
        anchor_year INTEGER NOT NULL,
        anchor_month INTEGER NOT NULL,
        anchor_day INTEGER NOT NULL,
        is_leap_month INTEGER NOT NULL DEFAULT 0,
        recurrence TEXT NOT NULL,
        reminder_offset_days INTEGER,
        reminder_hour INTEGER,
        reminder_minute INTEGER,
        created_at INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL DEFAULT 0
      )
    ''');
    legacy.execute('''
      INSERT INTO user_events (
        type, title, calendar_system, anchor_year, anchor_month, anchor_day,
        recurrence, reminder_offset_days, reminder_hour, reminder_minute
      ) VALUES ('general', 'Lễ cũ', 'solar', 2026, 8, 9, 'once', 1, 8, 30)
    ''');
    legacy.execute('PRAGMA user_version = 8');
    legacy.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final event = await db.select(db.userEvents).getSingle();
    expect(db.schemaVersion, 9);
    expect(event.reminderOffsetMinutes, 1440);
    expect(event.color, 'burgundy');
    expect(event.eventHour, isNull);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 9);
  });
}

UserEventDraft _draft({
  required String title,
  String? note,
  UserEventType type = UserEventType.general,
  EventCalendarSystem system = EventCalendarSystem.solar,
  int year = 2026,
  int month = 8,
  int day = 9,
  bool isLeapMonth = false,
  EventRecurrence recurrence = EventRecurrence.once,
  int? reminderOffsetDays,
  int? reminderOffsetMinutes,
  int? reminderHour,
  int? reminderMinute,
  int? eventHour,
  int? eventMinute,
  UserEventColor color = UserEventColor.burgundy,
}) {
  return UserEventDraft(
    type: type,
    title: title,
    note: note,
    calendarSystem: system,
    anchorYear: year,
    anchorMonth: month,
    anchorDay: day,
    isLeapMonth: isLeapMonth,
    recurrence: recurrence,
    eventHour: eventHour,
    eventMinute: eventMinute,
    color: color,
    reminderOffsetMinutes: reminderOffsetMinutes,
    reminderOffsetDays: reminderOffsetDays,
    reminderHour: reminderHour,
    reminderMinute: reminderMinute,
  );
}
