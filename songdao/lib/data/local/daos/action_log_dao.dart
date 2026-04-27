import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/action_logs.dart';
import '../tables/daily_actions.dart';

part 'action_log_dao.g.dart';

@DriftAccessor(tables: [ActionLogs, DailyActions])
class ActionLogDao extends DatabaseAccessor<AppDatabase> with _$ActionLogDaoMixin {
  ActionLogDao(super.db);

  Future<void> upsertActionLog(ActionLogsCompanion log) =>
      into(actionLogs).insertOnConflictUpdate(log);

  Future<void> markCompleted(String actionId, {String? note}) async {
    final existing = await (select(actionLogs)
          ..where((t) => t.actionId.equals(actionId)))
        .getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await into(actionLogs).insert(ActionLogsCompanion.insert(
        id: _logId(actionId),
        actionId: actionId,
        status: const Value('completed'),
        completedAt: Value(now),
        note: Value(note),
      ));
    } else {
      await (update(actionLogs)..where((t) => t.actionId.equals(actionId)))
          .write(ActionLogsCompanion(
        status: const Value('completed'),
        completedAt: Value(now),
        note: Value(note),
      ));
    }
  }

  Future<void> markSkipped(String actionId) async {
    final existing = await (select(actionLogs)
          ..where((t) => t.actionId.equals(actionId)))
        .getSingleOrNull();
    if (existing == null) {
      await into(actionLogs).insert(ActionLogsCompanion.insert(
        id: _logId(actionId),
        actionId: actionId,
        status: const Value('skipped'),
      ));
    } else {
      await (update(actionLogs)..where((t) => t.actionId.equals(actionId)))
          .write(const ActionLogsCompanion(status: Value('skipped')));
    }
  }

  Future<List<ActionLog>> getLogsForDate(String date) {
    final query = select(actionLogs).join([
      innerJoin(dailyActions, dailyActions.id.equalsExp(actionLogs.actionId)),
    ])
      ..where(dailyActions.date.equals(date));
    return query.map((row) => row.readTable(actionLogs)).get();
  }

  String _logId(String actionId) => 'log_$actionId';
}
