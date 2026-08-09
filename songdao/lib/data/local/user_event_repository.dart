import 'dart:math' as math;

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'vietnamese_lunar_calendar_service.dart';

enum UserEventType {
  general('general'),
  deathAnniversary('death_anniversary'),
  baptismAnniversary('baptism_anniversary'),
  patronalFeast('patronal_feast'),
  weddingAnniversary('wedding_anniversary');

  const UserEventType(this.storageValue);

  final String storageValue;

  static UserEventType fromStorage(String value) => values.firstWhere(
    (type) => type.storageValue == value,
    orElse: () => UserEventType.general,
  );
}

enum EventCalendarSystem {
  solar('solar'),
  lunar('lunar');

  const EventCalendarSystem(this.storageValue);

  final String storageValue;

  static EventCalendarSystem fromStorage(String value) => values.firstWhere(
    (system) => system.storageValue == value,
    orElse: () => EventCalendarSystem.solar,
  );
}

enum EventRecurrence {
  once('once'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const EventRecurrence(this.storageValue);

  final String storageValue;

  static EventRecurrence fromStorage(String value) => values.firstWhere(
    (recurrence) => recurrence.storageValue == value,
    orElse: () => EventRecurrence.once,
  );
}

enum UserEventColor {
  burgundy('burgundy'),
  blue('blue'),
  teal('teal'),
  green('green'),
  gold('gold'),
  orange('orange'),
  purple('purple'),
  gray('gray');

  const UserEventColor(this.storageValue);

  final String storageValue;

  static UserEventColor fromStorage(String value) => values.firstWhere(
    (color) => color.storageValue == value,
    orElse: () => UserEventColor.burgundy,
  );
}

class UserEventDraft {
  const UserEventDraft({
    required this.type,
    required this.title,
    required this.calendarSystem,
    required this.anchorYear,
    required this.anchorMonth,
    required this.anchorDay,
    required this.recurrence,
    this.note,
    this.isLeapMonth = false,
    this.eventHour,
    this.eventMinute,
    this.color = UserEventColor.burgundy,
    this.reminderOffsetMinutes,
    this.reminderOffsetDays,
    this.reminderHour,
    this.reminderMinute,
  });

  final UserEventType type;
  final String title;
  final String? note;
  final EventCalendarSystem calendarSystem;
  final int anchorYear;
  final int anchorMonth;
  final int anchorDay;
  final bool isLeapMonth;
  final EventRecurrence recurrence;
  final int? eventHour;
  final int? eventMinute;
  final UserEventColor color;
  final int? reminderOffsetMinutes;

  @Deprecated('Use reminderOffsetMinutes')
  final int? reminderOffsetDays;
  final int? reminderHour;
  final int? reminderMinute;

  bool get allDay => eventHour == null && eventMinute == null;

  int? get effectiveReminderOffsetMinutes =>
      reminderOffsetMinutes ??
      (reminderOffsetDays == null ? null : reminderOffsetDays! * 1440);

  bool get reminderEnabled => effectiveReminderOffsetMinutes != null;
}

class UserEventOccurrence {
  const UserEventOccurrence({required this.event, required this.date});

  final UserEvent event;
  final DateTime date;
}

class UserEventValidationException implements Exception {
  const UserEventValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserEventRepository {
  UserEventRepository(this._db, this._lunarCalendar);

  static const int maxTitleLength = 100;
  static const int maxNoteLength = 500;

  final AppDatabase _db;
  final VietnameseLunarCalendarService _lunarCalendar;

  Future<int> create(UserEventDraft draft) async {
    _validate(draft);
    final now = DateTime.now();
    return _db
        .into(_db.userEvents)
        .insert(_companion(draft, createdAt: now, updatedAt: now));
  }

  Future<void> updateEvent(int id, UserEventDraft draft) async {
    _validate(draft);
    final count =
        await (_db.update(_db.userEvents)
              ..where((table) => table.id.equals(id)))
            .write(_companion(draft, updatedAt: DateTime.now()));
    if (count == 0) {
      throw StateError('User event $id does not exist');
    }
  }

  Future<void> deleteEvent(int id) async {
    await (_db.delete(
      _db.userEvents,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<UserEvent?> getById(int id) => (_db.select(
    _db.userEvents,
  )..where((table) => table.id.equals(id))).getSingleOrNull();

  Future<List<UserEvent>> getAll() => (_db.select(
    _db.userEvents,
  )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();

  Future<List<UserEvent>> getReminderEnabledEvents() =>
      (_db.select(_db.userEvents)..where(
            (table) =>
                table.reminderOffsetMinutes.isNotNull() |
                table.reminderOffsetDays.isNotNull(),
          ))
          .get();

  Future<int> countReminderEnabled({int? excludingId}) async {
    final query = _db.select(_db.userEvents)
      ..where(
        (table) =>
            table.reminderOffsetMinutes.isNotNull() |
            table.reminderOffsetDays.isNotNull(),
      );
    if (excludingId != null) {
      query.where((table) => table.id.equals(excludingId).not());
    }
    return (await query.get()).length;
  }

  Future<List<UserEventOccurrence>> occurrencesBetween(
    DateTime start,
    DateTime end,
  ) async {
    final events = await getAll();
    final occurrences = <UserEventOccurrence>[];
    for (final event in events) {
      occurrences.addAll(occurrencesForEventBetween(event, start, end));
    }
    occurrences.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0
          ? byDate
          : a.event.createdAt.compareTo(b.event.createdAt);
    });
    return occurrences;
  }

  Future<List<UserEventOccurrence>> occurrencesOn(DateTime date) {
    final normalized = _dateOnly(date);
    return occurrencesBetween(normalized, normalized);
  }

  List<UserEventOccurrence> occurrencesForEventBetween(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final normalizedStart = _dateOnly(start);
    final normalizedEnd = _dateOnly(end);
    if (normalizedEnd.isBefore(normalizedStart)) {
      throw ArgumentError('end must not be before start');
    }

    final recurrence = EventRecurrence.fromStorage(event.recurrence);
    if (recurrence == EventRecurrence.once) {
      final occurrence = _anchorDate(event);
      return _isWithin(occurrence, normalizedStart, normalizedEnd)
          ? [UserEventOccurrence(event: event, date: occurrence)]
          : const [];
    }

    final system = EventCalendarSystem.fromStorage(event.calendarSystem);
    final dates = switch (recurrence) {
      EventRecurrence.daily => _dailyOccurrences(
        event,
        normalizedStart,
        normalizedEnd,
      ),
      EventRecurrence.weekly => _weeklyOccurrences(
        event,
        normalizedStart,
        normalizedEnd,
      ),
      EventRecurrence.monthly =>
        system == EventCalendarSystem.solar
            ? _solarMonthlyOccurrences(event, normalizedStart, normalizedEnd)
            : _lunarMonthlyOccurrences(event, normalizedStart, normalizedEnd),
      EventRecurrence.yearly =>
        system == EventCalendarSystem.solar
            ? _solarYearlyOccurrences(event, normalizedStart, normalizedEnd)
            : _lunarYearlyOccurrences(event, normalizedStart, normalizedEnd),
      EventRecurrence.once => <DateTime>{},
    };

    final sorted = dates.toList()..sort();
    return [
      for (final date in sorted) UserEventOccurrence(event: event, date: date),
    ];
  }

  UserEventOccurrence? nextOccurrenceOnOrAfter(UserEvent event, DateTime date) {
    final normalized = _dateOnly(date);
    final recurrence = EventRecurrence.fromStorage(event.recurrence);
    if (recurrence == EventRecurrence.once) {
      final anchor = _anchorDate(event);
      return anchor.isBefore(normalized)
          ? null
          : UserEventOccurrence(event: event, date: anchor);
    }

    final endYear = math.min(
      VietnameseLunarCalendarService.maxYear,
      normalized.year + 3,
    );
    final matches = occurrencesForEventBetween(
      event,
      normalized,
      DateTime(endYear, 12, 31),
    );
    return matches.isEmpty ? null : matches.first;
  }

  DateTime anchorDateFor(UserEvent event) => _anchorDate(event);

  UserEventsCompanion _companion(
    UserEventDraft draft, {
    DateTime? createdAt,
    required DateTime updatedAt,
  }) {
    final note = draft.note?.trim();
    return UserEventsCompanion(
      type: Value(draft.type.storageValue),
      title: Value(draft.title.trim()),
      note: Value(note == null || note.isEmpty ? null : note),
      calendarSystem: Value(draft.calendarSystem.storageValue),
      anchorYear: Value(draft.anchorYear),
      anchorMonth: Value(draft.anchorMonth),
      anchorDay: Value(draft.anchorDay),
      isLeapMonth: Value(
        draft.calendarSystem == EventCalendarSystem.lunar && draft.isLeapMonth,
      ),
      recurrence: Value(draft.recurrence.storageValue),
      eventHour: Value(draft.eventHour),
      eventMinute: Value(draft.eventMinute),
      color: Value(draft.color.storageValue),
      reminderOffsetMinutes: Value(draft.effectiveReminderOffsetMinutes),
      reminderOffsetDays: Value(
        draft.effectiveReminderOffsetMinutes != null &&
                draft.effectiveReminderOffsetMinutes! % 1440 == 0
            ? draft.effectiveReminderOffsetMinutes! ~/ 1440
            : null,
      ),
      reminderHour: Value(draft.reminderHour),
      reminderMinute: Value(draft.reminderMinute),
      createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  void _validate(UserEventDraft draft) {
    final title = draft.title.trim();
    if (title.isEmpty || title.length > maxTitleLength) {
      throw const UserEventValidationException('Invalid event title');
    }
    final note = draft.note?.trim();
    if (note != null && note.length > maxNoteLength) {
      throw const UserEventValidationException('Event note is too long');
    }
    if (draft.anchorYear < VietnameseLunarCalendarService.minYear ||
        draft.anchorYear > VietnameseLunarCalendarService.maxYear) {
      throw const UserEventValidationException('Event year is out of range');
    }

    if (draft.calendarSystem == EventCalendarSystem.solar) {
      final date = DateTime(
        draft.anchorYear,
        draft.anchorMonth,
        draft.anchorDay,
      );
      if (date.year != draft.anchorYear ||
          date.month != draft.anchorMonth ||
          date.day != draft.anchorDay) {
        throw const UserEventValidationException('Invalid Gregorian date');
      }
    } else {
      final lunarDate = LunarDateValue(
        year: draft.anchorYear,
        month: draft.anchorMonth,
        day: draft.anchorDay,
        isLeapMonth: draft.isLeapMonth,
      );
      if (_lunarCalendar.tryLunarToSolarExact(lunarDate) == null) {
        throw const UserEventValidationException('Invalid lunar date');
      }
    }

    final eventTimeParts = [draft.eventHour, draft.eventMinute];
    final presentEventTimeParts = eventTimeParts
        .where((part) => part != null)
        .length;
    if (presentEventTimeParts != 0 &&
        presentEventTimeParts != eventTimeParts.length) {
      throw const UserEventValidationException('Incomplete event time');
    }
    if (presentEventTimeParts == eventTimeParts.length &&
        (draft.eventHour! < 0 ||
            draft.eventHour! > 23 ||
            draft.eventMinute! < 0 ||
            draft.eventMinute! > 59)) {
      throw const UserEventValidationException('Invalid event time');
    }

    final offset = draft.effectiveReminderOffsetMinutes;
    final reminderClockParts = [draft.reminderHour, draft.reminderMinute];
    final presentReminderClockParts = reminderClockParts
        .where((part) => part != null)
        .length;
    if (offset == null && presentReminderClockParts != 0) {
      throw const UserEventValidationException('Incomplete reminder');
    }
    if (offset != null &&
        (offset < 0 ||
            offset > 10080 ||
            (draft.allDay &&
                !const [0, 1440, 2880, 4320, 10080].contains(offset)) ||
            (draft.allDay && presentReminderClockParts != 2) ||
            (!draft.allDay && presentReminderClockParts != 0))) {
      throw const UserEventValidationException('Invalid reminder');
    }
    if (offset != null &&
        draft.allDay &&
        (draft.reminderHour! < 0 ||
            draft.reminderHour! > 23 ||
            draft.reminderMinute! < 0 ||
            draft.reminderMinute! > 59)) {
      throw const UserEventValidationException('Invalid reminder time');
    }
  }

  DateTime _anchorDate(UserEvent event) {
    if (EventCalendarSystem.fromStorage(event.calendarSystem) ==
        EventCalendarSystem.solar) {
      return DateTime(event.anchorYear, event.anchorMonth, event.anchorDay);
    }
    return _lunarCalendar.lunarToSolarExact(
      LunarDateValue(
        year: event.anchorYear,
        month: event.anchorMonth,
        day: event.anchorDay,
        isLeapMonth: event.isLeapMonth,
      ),
    );
  }

  Set<DateTime> _dailyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final anchor = _anchorDate(event);
    if (anchor.isAfter(end)) {
      return {};
    }
    var cursor = anchor;
    if (cursor.isBefore(start)) {
      cursor = start;
    }
    final dates = <DateTime>{};
    for (; !cursor.isAfter(end); cursor = cursor.add(const Duration(days: 1))) {
      dates.add(cursor);
    }
    return dates;
  }

  Set<DateTime> _weeklyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final anchor = _anchorDate(event);
    if (anchor.isAfter(end)) {
      return {};
    }
    var cursor = anchor;
    if (cursor.isBefore(start)) {
      final days = start.difference(anchor).inDays;
      cursor = anchor.add(Duration(days: ((days + 6) ~/ 7) * 7));
    }
    final dates = <DateTime>{};
    for (; !cursor.isAfter(end); cursor = cursor.add(const Duration(days: 7))) {
      dates.add(cursor);
    }
    return dates;
  }

  Set<DateTime> _solarMonthlyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>{};
    var cursor = DateTime(math.max(start.year, event.anchorYear), start.month);
    if (cursor.isBefore(DateTime(event.anchorYear, event.anchorMonth))) {
      cursor = DateTime(event.anchorYear, event.anchorMonth);
    }
    while (!cursor.isAfter(DateTime(end.year, end.month))) {
      final lastDay = DateTime(cursor.year, cursor.month + 1, 0).day;
      final occurrence = DateTime(
        cursor.year,
        cursor.month,
        math.min(event.anchorDay, lastDay),
      );
      if (_isWithin(occurrence, start, end)) {
        dates.add(occurrence);
      }
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return dates;
  }

  Set<DateTime> _lunarMonthlyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>{};
    final firstYear = math.max(
      VietnameseLunarCalendarService.minYear,
      math.min(event.anchorYear, start.year - 1),
    );
    final lastYear = math.min(
      VietnameseLunarCalendarService.maxYear,
      end.year + 1,
    );
    for (var year = firstYear; year <= lastYear; year += 1) {
      if (year < event.anchorYear) {
        continue;
      }
      for (var month = 1; month <= 12; month += 1) {
        final occurrence = _lunarMonthlyOccurrence(event, year, month);
        if (_isWithin(occurrence, start, end)) {
          dates.add(occurrence);
        }
      }
    }
    return dates;
  }

  Set<DateTime> _solarYearlyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>{};
    final firstYear = math.max(start.year, event.anchorYear);
    for (var year = firstYear; year <= end.year; year += 1) {
      final occurrence = _solarOccurrence(event, year);
      if (_isWithin(occurrence, start, end)) {
        dates.add(occurrence);
      }
    }
    return dates;
  }

  Set<DateTime> _lunarYearlyOccurrences(
    UserEvent event,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>{};
    final firstYear = math.max(
      VietnameseLunarCalendarService.minYear,
      start.year - 1,
    );
    final lastYear = math.min(
      VietnameseLunarCalendarService.maxYear,
      end.year + 1,
    );
    for (var lunarYear = firstYear; lunarYear <= lastYear; lunarYear += 1) {
      if (lunarYear < event.anchorYear) {
        continue;
      }
      final occurrence = _lunarCalendar.lunarOccurrence(
        anchor: LunarDateValue(
          year: event.anchorYear,
          month: event.anchorMonth,
          day: event.anchorDay,
          isLeapMonth: event.isLeapMonth,
        ),
        targetYear: lunarYear,
      );
      if (_isWithin(occurrence, start, end)) {
        dates.add(occurrence);
      }
    }
    return dates;
  }

  DateTime _lunarMonthlyOccurrence(UserEvent event, int year, int month) {
    final dayOptions = event.anchorDay == 30
        ? const [30, 29]
        : [event.anchorDay];
    for (final day in dayOptions) {
      final occurrence = _lunarCalendar.tryLunarToSolarExact(
        LunarDateValue(year: year, month: month, day: day),
      );
      if (occurrence != null) {
        return occurrence;
      }
    }
    throw StateError('No valid lunar monthly occurrence');
  }

  DateTime _solarOccurrence(UserEvent event, int year) {
    final lastDay = DateTime(year, event.anchorMonth + 1, 0).day;
    return DateTime(
      year,
      event.anchorMonth,
      math.min(event.anchorDay, lastDay),
    );
  }

  bool _isWithin(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
