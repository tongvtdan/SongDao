import 'package:drift/drift.dart';

import 'app_database.dart';

class UserSettingsKeys {
  const UserSettingsKeys._();

  static const locale = 'locale';
  static const showLunarDate = 'show_lunar_date';
  static const selectedChurchId = 'selected_church_id';
}

class UserSettingsRepository {
  UserSettingsRepository(this.db);

  final AppDatabase db;

  Future<String> locale() async {
    final setting = await _get(UserSettingsKeys.locale);
    return setting?.value ?? 'vi';
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
}
