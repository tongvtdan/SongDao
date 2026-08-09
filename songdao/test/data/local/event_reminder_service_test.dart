import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/event_reminder_service.dart';
import 'package:songdao/data/local/user_event_repository.dart';
import 'package:songdao/data/local/user_settings_repository.dart';
import 'package:songdao/data/local/vietnamese_lunar_calendar_service.dart';
import 'package:songdao/notifications/local_notification_service.dart';

void main() {
  group('EventReminderService', () {
    late AppDatabase db;
    late UserEventRepository repository;
    late _FakeNotifications notifications;
    late EventReminderService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = UserEventRepository(
        db,
        const VietnameseLunarCalendarService(),
      );
      notifications = _FakeNotifications();
      service = EventReminderService(
        repository,
        UserSettingsRepository(db),
        notifications,
        now: () => DateTime(2026, 8, 9, 10),
      );
    });

    tearDown(() => db.close());

    test('keeps permission denial explicit for the editor', () async {
      notifications.permissionGranted = false;

      expect(await service.requestPermission(), isFalse);
      expect(notifications.permissionRequests, 1);
    });

    test(
      'applies offset and time and only repeats ordinary solar dates',
      () async {
        final solarId = await repository.create(
          _draft(
            title: 'Kỷ niệm Hôn phối',
            system: EventCalendarSystem.solar,
            month: 8,
            day: 10,
            offset: 1,
          ),
        );
        const lunarCalendar = VietnameseLunarCalendarService();
        final lunarAnchor = lunarCalendar.solarToLunar(DateTime(2026, 8, 10));
        final lunarId = await repository.create(
          _draft(
            title: 'Ngày giỗ',
            system: EventCalendarSystem.lunar,
            year: lunarAnchor.year,
            month: lunarAnchor.month,
            day: lunarAnchor.day,
            isLeapMonth: lunarAnchor.isLeapMonth,
            offset: 0,
          ),
        );
        final leapDayId = await repository.create(
          _draft(
            title: 'Ngày nhuận',
            system: EventCalendarSystem.solar,
            year: 2024,
            month: 2,
            day: 29,
            offset: 0,
          ),
        );

        final result = await service.refreshScheduledReminders();

        expect(result.scheduledCount, greaterThanOrEqualTo(3));
        final solar = notifications.callFor(solarId);
        expect(solar.scheduledDate, DateTime(2026, 8, 9, 19));
        expect(solar.matchDateTimeComponents, DateTimeComponents.dateAndTime);
        expect(solar.payload, 'songdao:///calendar?eventId=$solarId');
        expect(notifications.callFor(lunarId).matchDateTimeComponents, isNull);
        expect(
          notifications.callFor(leapDayId).matchDateTimeComponents,
          isNull,
        );
      },
    );

    test('schedules only the next 50 event reminders', () async {
      for (var index = 0; index < 51; index += 1) {
        await repository.create(
          _draft(title: 'Sự kiện $index', month: 12, day: 1, offset: 0),
        );
      }

      final result = await service.refreshScheduledReminders();

      expect(result.scheduledCount, EventReminderService.maxScheduledEvents);
      expect(result.skippedCount, 1);
      expect(notifications.scheduled, hasLength(50));
    });

    test(
      'moves a native reminder to the next occurrence when today passed',
      () async {
        final id = await repository.create(
          _draft(
            title: 'Cầu nguyện sáng',
            day: 9,
            recurrence: EventRecurrence.daily,
            eventHour: 9,
            eventMinute: 0,
            reminderOffsetMinutes: 0,
          ),
        );

        await service.refreshScheduledReminders();

        expect(
          notifications.callFor(id).scheduledDate,
          DateTime(2026, 8, 10, 9),
        );
        expect(
          notifications.callFor(id).matchDateTimeComponents,
          DateTimeComponents.time,
        );
      },
    );

    test(
      'rolls yearly reminders when the date shifts across leap day',
      () async {
        final id = await repository.create(
          _draft(title: 'Ngày khai giảng', month: 3, day: 1, offset: 1),
        );

        await service.refreshScheduledReminders();

        final calls = notifications.scheduled
            .where((call) => call.eventId == id)
            .toList();
        expect(calls, isNotEmpty);
        expect(calls.first.matchDateTimeComponents, isNull);
        expect(calls.first.scheduledDate, DateTime(2027, 2, 28, 19));
      },
    );

    test('reschedules after an edit and deletion', () async {
      final id = await repository.create(
        _draft(title: 'Quan thầy', month: 8, day: 10, offset: 0),
      );
      await service.refreshScheduledReminders();
      expect(
        notifications.callFor(id).scheduledDate,
        DateTime(2026, 8, 10, 19),
      );

      await repository.updateEvent(
        id,
        _draft(title: 'Quan thầy', month: 8, day: 11, offset: 0),
      );
      await service.refreshScheduledReminders();

      expect(notifications.cancelAllCalls, 2);
      expect(
        notifications.callFor(id).scheduledDate,
        DateTime(2026, 8, 11, 19),
      );

      await repository.deleteEvent(id);
      await service.refreshScheduledReminders();
      expect(notifications.cancelAllCalls, 3);
      expect(await repository.getById(id), isNull);
    });
  });
}

UserEventDraft _draft({
  required String title,
  EventCalendarSystem system = EventCalendarSystem.solar,
  int year = 2026,
  int month = 8,
  int day = 10,
  bool isLeapMonth = false,
  int? offset,
  EventRecurrence recurrence = EventRecurrence.yearly,
  int? eventHour,
  int? eventMinute,
  int? reminderOffsetMinutes,
}) {
  return UserEventDraft(
    type: UserEventType.general,
    title: title,
    calendarSystem: system,
    anchorYear: year,
    anchorMonth: month,
    anchorDay: day,
    isLeapMonth: isLeapMonth,
    recurrence: recurrence,
    eventHour: eventHour,
    eventMinute: eventMinute,
    reminderOffsetMinutes: reminderOffsetMinutes,
    reminderOffsetDays: offset,
    reminderHour: offset == null ? null : 19,
    reminderMinute: offset == null ? null : 0,
  );
}

class _ScheduledCall {
  const _ScheduledCall({
    required this.notificationId,
    required this.scheduledDate,
    required this.payload,
    required this.matchDateTimeComponents,
  });

  final int notificationId;
  final DateTime scheduledDate;
  final String payload;
  final DateTimeComponents? matchDateTimeComponents;

  int get eventId => int.parse(Uri.parse(payload).queryParameters['eventId']!);
}

class _FakeNotifications extends LocalNotificationService {
  bool permissionGranted = true;
  int permissionRequests = 0;
  int cancelAllCalls = 0;
  final List<_ScheduledCall> scheduled = [];

  _ScheduledCall callFor(int eventId) =>
      scheduled.firstWhere((call) => call.eventId == eventId);

  @override
  Future<bool> requestReminderPermission() async {
    permissionRequests += 1;
    return permissionGranted;
  }

  @override
  Future<void> configureTimezone() async {}

  @override
  Future<void> cancelAllPersonalEventReminders() async {
    cancelAllCalls += 1;
    scheduled.clear();
  }

  @override
  Future<void> schedulePersonalEventReminder({
    required int notificationId,
    required DateTime scheduledDate,
    required String title,
    required String body,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
    required String channelName,
    required String channelDescription,
  }) async {
    scheduled.add(
      _ScheduledCall(
        notificationId: notificationId,
        scheduledDate: scheduledDate,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      ),
    );
  }
}
