import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/action_logs.dart';
import '../tables/daily_actions.dart';
import '../widget_snapshot_service.dart';

part 'action_log_dao.g.dart';

@DriftAccessor(tables: [ActionLogs, DailyActions])
class ActionLogDao extends DatabaseAccessor<AppDatabase>
    with _$ActionLogDaoMixin {
  ActionLogDao(super.db);

  Future<void> upsertActionLog(ActionLogsCompanion log) =>
      into(actionLogs).insertOnConflictUpdate(log);

  Future<void> markCompleted(String actionId, {String? note}) async {
    final action = await _getAction(actionId);
    final existing = await (select(
      actionLogs,
    )..where((t) => t.actionId.equals(actionId))).getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await into(actionLogs).insert(
        ActionLogsCompanion.insert(
          id: _logId(actionId),
          actionId: actionId,
          date: action.date,
          status: const Value('completed'),
          completedAt: Value(now),
          note: Value(note),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (update(
        actionLogs,
      )..where((t) => t.actionId.equals(actionId))).write(
        ActionLogsCompanion(
          status: const Value('completed'),
          completedAt: Value(now),
          note: Value(note),
          updatedAt: Value(now),
        ),
      );
    }
    await WidgetSnapshotService(
      db,
    ).regenerateForDate(action.date, locale: action.locale);
  }

  Future<void> saveNote(String actionId, String note) async {
    final action = await _getAction(actionId);
    final existing = await (select(
      actionLogs,
    )..where((t) => t.actionId.equals(actionId))).getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await into(actionLogs).insert(
        ActionLogsCompanion.insert(
          id: _logId(actionId),
          actionId: actionId,
          date: action.date,
          note: Value(note),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (update(actionLogs)..where((t) => t.actionId.equals(actionId)))
          .write(ActionLogsCompanion(note: Value(note), updatedAt: Value(now)));
    }
    await WidgetSnapshotService(
      db,
    ).regenerateForDate(action.date, locale: action.locale);
  }

  Future<void> markSkipped(String actionId) async {
    final action = await _getAction(actionId);
    final existing = await (select(
      actionLogs,
    )..where((t) => t.actionId.equals(actionId))).getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await into(actionLogs).insert(
        ActionLogsCompanion.insert(
          id: _logId(actionId),
          actionId: actionId,
          date: action.date,
          status: const Value('skipped'),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (update(
        actionLogs,
      )..where((t) => t.actionId.equals(actionId))).write(
        ActionLogsCompanion(
          status: const Value('skipped'),
          updatedAt: Value(now),
        ),
      );
    }
    await WidgetSnapshotService(
      db,
    ).regenerateForDate(action.date, locale: action.locale);
  }

  Future<List<ActionLog>> getLogsForDate(String date) =>
      (select(actionLogs)..where((t) => t.date.equals(date))).get();

  Future<DailyAction> _getAction(String actionId) =>
      (select(dailyActions)..where((t) => t.id.equals(actionId))).getSingle();

  String _logId(String actionId) => 'log_$actionId';
}
