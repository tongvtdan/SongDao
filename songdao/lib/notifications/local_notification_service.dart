import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationRoutes {
  const NotificationRoutes._();

  static const todayUri = 'songdao:///today';

  static String routeFromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return '/today';
    }
    final uri = Uri.tryParse(payload.trim());
    if (uri == null) {
      return '/today';
    }
    if (uri.scheme == 'songdao') {
      return uri.path.isEmpty ? '/today' : uri.path;
    }
    if (uri.path.startsWith('/')) {
      return uri.path;
    }
    return '/today';
  }
}

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const dailyReminderBaseId = 4100;
  static const dailyReminderWindowDays = 14;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<String?> initialize({
    required void Function(String route) onOpenRoute,
  }) async {
    if (_initialized) {
      return null;
    }
    _configureTimezone();
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

  void _configureTimezone() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }
}

final localNotificationService = LocalNotificationService();
