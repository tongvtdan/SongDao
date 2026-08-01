import 'package:drift/drift.dart';

import 'app_database.dart';

class UserSettingsKeys {
  const UserSettingsKeys._();

  static const locale = 'locale';
  static const showLunarDate = 'show_lunar_date';
  static const selectedChurchId = 'selected_church_id';
  static const dailyReminderEnabled = 'daily_reminder_enabled';
  static const dailyReminderHour = 'daily_reminder_hour';
  static const dailyReminderMinute = 'daily_reminder_minute';
  static const seasonalIconEnabled = 'seasonal_icon_enabled';
  static const selectedAppIconVariant = 'selected_app_icon_variant';

  static String activeCalendarContent(String locale) {
    return 'active_calendar_content_$locale';
  }
}

const supportedAppLocaleCodes = ['vi'];
const defaultAppLocaleCode = 'vi';

class DailyReminderSettings {
  const DailyReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;
}

class UserSettingsRepository {
  UserSettingsRepository(this.db);

  final AppDatabase db;

  Future<String> locale() async {
    final setting = await _get(UserSettingsKeys.locale);
    final value = setting?.value;
    return supportedAppLocaleCodes.contains(value)
        ? value!
        : defaultAppLocaleCode;
  }

  Future<void> setLocale(String value) {
    if (!supportedAppLocaleCodes.contains(value)) {
      throw ArgumentError.value(value, 'value', 'Unsupported app locale');
    }
    return set(UserSettingsKeys.locale, value);
  }

  Future<bool> showLunarDate() async {
    final localeValue = await locale();
    if (localeValue != 'vi') {
      return false;
    }
    final setting = await _get(UserSettingsKeys.showLunarDate);
    return setting?.value != 'false';
  }

  Future<void> setShowLunarDate(bool value) {
    return set(UserSettingsKeys.showLunarDate, value ? 'true' : 'false');
  }

  Future<String?> selectedChurchId() async {
    final setting = await _get(UserSettingsKeys.selectedChurchId);
    return setting?.value;
  }

  Future<void> setSelectedChurchId(String churchId) {
    return set(UserSettingsKeys.selectedChurchId, churchId);
  }

  Future<DailyReminderSettings> dailyReminder() async {
    final enabled = await _get(UserSettingsKeys.dailyReminderEnabled);
    final hour = await _get(UserSettingsKeys.dailyReminderHour);
    final minute = await _get(UserSettingsKeys.dailyReminderMinute);
    return DailyReminderSettings(
      enabled: enabled?.value == 'true',
      hour: _boundedInt(hour?.value, fallback: 7, min: 0, max: 23),
      minute: _boundedInt(minute?.value, fallback: 0, min: 0, max: 59),
    );
  }

  Future<void> setDailyReminderEnabled(bool value) {
    return set(UserSettingsKeys.dailyReminderEnabled, value ? 'true' : 'false');
  }

  Future<void> setDailyReminderTime({
    required int hour,
    required int minute,
  }) async {
    await set(UserSettingsKeys.dailyReminderHour, hour.toString());
    await set(UserSettingsKeys.dailyReminderMinute, minute.toString());
  }

  Future<bool> seasonalIconEnabled() async {
    final setting = await _get(UserSettingsKeys.seasonalIconEnabled);
    return setting?.value == 'true';
  }

  Future<void> setSeasonalIconEnabled(bool value) {
    return set(UserSettingsKeys.seasonalIconEnabled, value ? 'true' : 'false');
  }

  Future<String> selectedAppIconVariant() async {
    final setting = await _get(UserSettingsKeys.selectedAppIconVariant);
    return setting?.value ?? 'primary';
  }

  Future<void> setSelectedAppIconVariant(String value) {
    return set(UserSettingsKeys.selectedAppIconVariant, value);
  }

  Future<void> set(String key, String value) {
    return db
        .into(db.userSettings)
        .insertOnConflictUpdate(
          UserSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<UserSetting?> _get(String key) {
    return (db.select(
      db.userSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  int _boundedInt(
    String? value, {
    required int fallback,
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < min || parsed > max) {
      return fallback;
    }
    return parsed;
  }
}
