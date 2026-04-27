import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'daily_action_engine.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final dailyActionEngineProvider = Provider<DailyActionEngine>((ref) {
  return DailyActionEngine(ref.watch(databaseProvider));
});
