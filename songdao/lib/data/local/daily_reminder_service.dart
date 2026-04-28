import 'daily_action_engine.dart';
import 'user_settings_repository.dart';
import '../../notifications/local_notification_service.dart';

class DailyReminderService {
  DailyReminderService(this._settings, this._engine, this._notifications);

  final UserSettingsRepository _settings;
  final DailyActionEngine _engine;
  final LocalNotificationService _notifications;

  Future<bool> enableDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final allowed = await _notifications.requestReminderPermission();
    if (!allowed) {
      await _settings.setDailyReminderEnabled(false);
      await _notifications.cancelDailyReminders();
      return false;
    }
    await _settings.setDailyReminderTime(hour: hour, minute: minute);
    await _settings.setDailyReminderEnabled(true);
    await refreshScheduledReminders();
    return true;
  }

  Future<void> disableDailyReminder() async {
    await _settings.setDailyReminderEnabled(false);
    await _notifications.cancelDailyReminders();
  }

  Future<void> refreshScheduledReminders() async {
    final reminder = await _settings.dailyReminder();
    if (!reminder.enabled) {
      await _notifications.cancelDailyReminders();
      return;
    }

    await _notifications.cancelDailyReminders();
    final now = DateTime.now();
    for (
      var offset = 0;
      offset < LocalNotificationService.dailyReminderWindowDays;
      offset += 1
    ) {
      final date = DateTime(now.year, now.month, now.day + offset);
      final action = await _engine.getOrCreateActionForDate(_dateKey(date));
      await _notifications.scheduleDailyReminder(
        offset: offset,
        date: date,
        hour: reminder.hour,
        minute: reminder.minute,
        body: action.prompt.isEmpty
            ? DailyActionEngine.fallbackPrompt
            : action.prompt,
      );
    }
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
