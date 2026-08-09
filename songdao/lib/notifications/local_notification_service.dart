import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationRoutes {
  const NotificationRoutes._();

  static const todayUri = 'songdao:///today';

  static String calendarEventUri(int eventId) {
    return 'songdao:///calendar?eventId=$eventId';
  }

  static String routeFromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return '/today';
    }
    final uri = Uri.tryParse(payload.trim());
    if (uri == null) {
      return '/today';
    }
    if (uri.scheme == 'songdao') {
      return _pathWithQuery(uri);
    }
    if (uri.path.startsWith('/')) {
      return _pathWithQuery(uri);
    }
    return '/today';
  }

  static String _pathWithQuery(Uri uri) {
    final path = uri.path.isEmpty ? '/today' : uri.path;
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }
}

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const dailyReminderBaseId = 4100;
  static const dailyReminderWindowDays = 14;
  static const personalEventReminderBaseId = 100000;
  static const maxPersonalEventReminders = 50;
  static const personalEventReminderUpperBound =
      personalEventReminderBaseId + maxPersonalEventReminders;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<String?> initialize({
    required void Function(String route) onOpenRoute,
  }) async {
    if (_initialized) {
      return null;
    }
    await configureTimezone();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_songdao'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        onOpenRoute(NotificationRoutes.routeFromPayload(response.payload));
      },
    );
    _initialized = true;

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp != true) {
      return null;
    }
    return NotificationRoutes.routeFromPayload(
      launchDetails?.notificationResponse?.payload,
    );
  }

  Future<bool> requestReminderPermission() async {
    if (kIsWeb) {
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            sound: true,
            badge: false,
          ) ??
          false;
    }
    return true;
  }

  Future<void> cancelDailyReminders() async {
    for (var offset = 0; offset < dailyReminderWindowDays; offset += 1) {
      await _plugin.cancel(id: dailyReminderBaseId + offset);
    }
  }

  Future<void> cancelAllPersonalEventReminders() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.id >= personalEventReminderBaseId &&
          notification.id < personalEventReminderUpperBound) {
        await _plugin.cancel(id: notification.id);
      }
    }
  }

  int personalEventNotificationId(int slot) {
    if (slot < 0 || slot >= maxPersonalEventReminders) {
      throw RangeError.value(slot, 'slot');
    }
    return personalEventReminderBaseId + slot;
  }

  Future<void> scheduleDailyReminder({
    required int offset,
    required DateTime date,
    required int hour,
    required int minute,
    required String body,
  }) async {
    if (kIsWeb) {
      return;
    }
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }
    await _plugin.zonedSchedule(
      id: dailyReminderBaseId + offset,
      scheduledDate: scheduledDate,
      title: 'Sống Đạo hôm nay',
      body: body,
      payload: NotificationRoutes.todayUri,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_practice',
          'Nhắc nhở sống đạo',
          channelDescription: 'Nhắc nhẹ để quay lại việc sống đạo hôm nay.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
    );
  }

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
    if (kIsWeb) {
      return;
    }
    final localDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );
    if (!localDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }
    await _plugin.zonedSchedule(
      id: notificationId,
      scheduledDate: localDate,
      title: title,
      body: body,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'personal_events',
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
          threadIdentifier: 'personal_events',
        ),
      ),
    );
  }

  Future<void> configureTimezone() async {
    tz_data.initializeTimeZones();
    if (kIsWeb) {
      tz.setLocalLocation(tz.UTC);
      return;
    }
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } on Object {
      // Keep initialization safe if a platform does not expose its timezone.
      tz.setLocalLocation(tz.UTC);
    }
  }
}

final localNotificationService = LocalNotificationService();
