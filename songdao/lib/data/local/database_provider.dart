import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_info_service.dart';
import 'app_database.dart';
import 'app_icon_service.dart';
import 'daily_reminder_service.dart';
import 'daily_action_engine.dart';
import 'mass_service.dart';
import 'user_settings_repository.dart';
import '../../notifications/local_notification_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final dailyActionEngineProvider = Provider<DailyActionEngine>((ref) {
  return DailyActionEngine(ref.watch(databaseProvider));
});

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepository(ref.watch(databaseProvider));
});

final massServiceProvider = Provider<MassService>((ref) {
  return MassService(ref.watch(databaseProvider));
});

final appIconServiceProvider = Provider<AppIconService>((ref) {
  final db = ref.watch(databaseProvider);
  return AppIconService(db: db, settings: UserSettingsRepository(db));
});

final appInfoServiceProvider = Provider<AppInfoService>((ref) {
  return const AppInfoService();
});

final dailyReminderServiceProvider = Provider<DailyReminderService>((ref) {
  final db = ref.watch(databaseProvider);
  return DailyReminderService(
    UserSettingsRepository(db),
    DailyActionEngine(db),
    localNotificationService,
  );
});
