import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/database_provider.dart';
import 'package:songdao/data/local/event_reminder_service.dart';
import 'package:songdao/data/local/user_event_repository.dart';
import 'package:songdao/data/local/user_settings_repository.dart';
import 'package:songdao/data/local/vietnamese_lunar_calendar_service.dart';
import 'package:songdao/features/calendar/calendar_screen.dart';
import 'package:songdao/features/calendar/user_event_editor_screen.dart';
import 'package:songdao/l10n/app_localizations.dart';
import 'package:songdao/notifications/local_notification_service.dart';

void main() {
  testWidgets(
    'creates all five event types with the expected recurrence default',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final reminders = _reminderService(db);
      const cases = [
        ('Sự kiện', UserEventType.general, EventRecurrence.once),
        ('Ngày giỗ', UserEventType.deathAnniversary, EventRecurrence.yearly),
        (
          'Kỷ niệm Rửa Tội',
          UserEventType.baptismAnniversary,
          EventRecurrence.yearly,
        ),
        ('Lễ quan thầy', UserEventType.patronalFeast, EventRecurrence.yearly),
        (
          'Kỷ niệm Hôn phối',
          UserEventType.weddingAnniversary,
          EventRecurrence.yearly,
        ),
      ];
      await tester.pumpWidget(
        _testApp(db, reminders, const Scaffold(body: SizedBox.shrink())),
      );
      await tester.pumpAndSettle();

      for (var index = 0; index < cases.length; index += 1) {
        final eventCase = cases[index];
        await _pushScreen(
          tester,
          UserEventEditorScreen(initialDate: DateTime(2026, 12, 1)),
        );

        await tester.tap(find.byType(DropdownButtonFormField<UserEventType>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(eventCase.$1).last);
        await tester.pumpAndSettle();

        final recurrence = tester
            .widget<DropdownButtonFormField<EventRecurrence>>(
              find.byType(DropdownButtonFormField<EventRecurrence>),
            );
        expect(recurrence.initialValue, eventCase.$3);

        await tester.enterText(
          find.byType(TextFormField).first,
          '${eventCase.$1} ${index + 1}',
        );
        final save = find.widgetWithText(FilledButton, 'Lưu');
        await tester.scrollUntilVisible(
          save,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(save);
        await tester.pumpAndSettle();
      }

      final events = await db.select(db.userEvents).get();
      expect(events, hasLength(cases.length));
      expect(
        events.map((event) => event.type),
        cases.map((eventCase) => eventCase.$2.storageValue),
      );
    },
  );

  testWidgets('validates title and shows the lunar editor with conversion', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      _testApp(
        db,
        _reminderService(db),
        const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();
    await _pushScreen(
      tester,
      UserEventEditorScreen(initialDate: DateTime(2026, 2, 17)),
    );

    await tester.tap(find.text('Âm lịch'));
    await tester.pumpAndSettle();
    expect(find.text('Dương lịch: 17/02/2026'), findsOneWidget);

    final save = find.widgetWithText(FilledButton, 'Lưu');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(find.text('Hãy nhập tên sự kiện.'), findsOneWidget);
    expect(await db.select(db.userEvents).get(), isEmpty);
  });

  testWidgets(
    'requests reminder permission explicitly when permission is denied',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final notifications = _NoopNotifications(permissionGranted: false);
      final reminders = _reminderService(db, notifications: notifications);
      await tester.pumpWidget(
        _testApp(db, reminders, const Scaffold(body: SizedBox.shrink())),
      );
      await tester.pumpAndSettle();

      expect(await reminders.requestPermission(), isFalse);
      expect(notifications.permissionRequests, 1);
    },
  );

  testWidgets('deletes an entire yearly series from Calendar', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserEventRepository(
      db,
      const VietnameseLunarCalendarService(),
    );
    final id = await repository.create(
      const UserEventDraft(
        type: UserEventType.patronalFeast,
        title: 'Lễ quan thầy thánh Giuse',
        calendarSystem: EventCalendarSystem.solar,
        anchorYear: 2026,
        anchorMonth: 8,
        anchorDay: 9,
        recurrence: EventRecurrence.yearly,
      ),
    );
    await tester.pumpWidget(
      _testApp(
        db,
        _reminderService(db),
        CalendarScreen(initialDate: DateTime(2026, 8, 9)),
        extraOverrides: [
          seedContentBootstrapProvider.overrideWith((ref) async => []),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('user-event-marker-2026-08-09')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Lễ quan thầy thánh Giuse'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Xóa sự kiện'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(await repository.getById(id), isNull);
  });

  testWidgets('edits an existing event without duplicating its series', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserEventRepository(
      db,
      const VietnameseLunarCalendarService(),
    );
    final id = await repository.create(
      const UserEventDraft(
        type: UserEventType.baptismAnniversary,
        title: 'Ngày Rửa Tội',
        calendarSystem: EventCalendarSystem.solar,
        anchorYear: 2010,
        anchorMonth: 4,
        anchorDay: 3,
        recurrence: EventRecurrence.yearly,
      ),
    );
    await tester.pumpWidget(
      _testApp(
        db,
        _reminderService(db),
        const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();
    await _pushScreen(
      tester,
      UserEventEditorScreen(initialDate: DateTime(2026, 8, 9), eventId: id),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Kỷ niệm Rửa Tội');
    final save = find.widgetWithText(FilledButton, 'Lưu');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();

    final events = await repository.getAll();
    expect(events, hasLength(1));
    expect(events.single.id, id);
    expect(events.single.title, 'Kỷ niệm Rửa Tội');
    expect(events.single.recurrence, EventRecurrence.yearly.storageValue);
  });
}

Future<void> _pushScreen(WidgetTester tester, Widget screen) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.push(MaterialPageRoute<void>(builder: (context) => screen));
  await tester.pumpAndSettle();
}

Widget _testApp(
  AppDatabase db,
  EventReminderService reminders,
  Widget home, {
  List<Override> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      eventReminderServiceProvider.overrideWithValue(reminders),
      ...extraOverrides,
    ],
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

EventReminderService _reminderService(
  AppDatabase db, {
  _NoopNotifications? notifications,
}) {
  return EventReminderService(
    UserEventRepository(db, const VietnameseLunarCalendarService()),
    UserSettingsRepository(db),
    notifications ?? _NoopNotifications(),
    now: () => DateTime(2026, 8, 9, 10),
  );
}

class _NoopNotifications extends LocalNotificationService {
  _NoopNotifications({this.permissionGranted = true});

  final bool permissionGranted;
  int permissionRequests = 0;

  @override
  Future<bool> requestReminderPermission() async {
    permissionRequests += 1;
    return permissionGranted;
  }

  @override
  Future<void> configureTimezone() async {}

  @override
  Future<void> cancelAllPersonalEventReminders() async {}

  @override
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
  }) async {}
}
