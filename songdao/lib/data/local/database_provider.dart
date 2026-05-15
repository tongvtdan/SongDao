import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
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

final dailyReminderServiceProvider = Provider<DailyReminderService>((ref) {
  final db = ref.watch(databaseProvider);
  return DailyReminderService(
    UserSettingsRepository(db),
    DailyActionEngine(db),
    localNotificationService,
  );
});
