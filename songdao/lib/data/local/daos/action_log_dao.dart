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
    final normalizedNote = _normalizeNote(note);
    if (existing == null) {
      await into(actionLogs).insert(
        ActionLogsCompanion.insert(
          id: _logId(actionId),
          actionId: actionId,
          date: action.date,
          status: const Value('completed'),
          completedAt: Value(now),
          note: Value(normalizedNote),
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
          note: Value(normalizedNote),
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
    final normalizedNote = _normalizeNote(note);
    if (existing == null) {
      await into(actionLogs).insert(
        ActionLogsCompanion.insert(
          id: _logId(actionId),
          actionId: actionId,
          date: action.date,
          note: Value(normalizedNote),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (update(
        actionLogs,
      )..where((t) => t.actionId.equals(actionId))).write(
        ActionLogsCompanion(note: Value(normalizedNote), updatedAt: Value(now)),
      );
    }
    await WidgetSnapshotService(
      db,
    ).regenerateForDate(action.date, locale: action.locale);
  }

  Future<void> clearNote(String actionId) => saveNote(actionId, '');

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

  Future<List<JournalEntry>> getJournalEntries({String query = ''}) async {
    final normalizedQuery = query.trim().toLowerCase();
    final logs =
        await (select(actionLogs)
              ..where((t) => t.note.isNotNull())
              ..orderBy([
                (t) =>
                    OrderingTerm(expression: t.date, mode: OrderingMode.desc),
                (t) => OrderingTerm(
                  expression: t.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    final entries = <JournalEntry>[];
    for (final log in logs) {
      final note = _normalizeNote(log.note);
      if (note == null) {
        continue;
      }
      final action = await (select(
        dailyActions,
      )..where((t) => t.id.equals(log.actionId))).getSingleOrNull();
      if (action == null) {
        continue;
      }
      if (normalizedQuery.isNotEmpty) {
        final searchable = '${action.prompt} $note'.toLowerCase();
        if (!searchable.contains(normalizedQuery)) {
          continue;
        }
      }
      entries.add(JournalEntry(log: log, action: action, note: note));
    }
    return entries;
  }

  Future<DailyAction> _getAction(String actionId) =>
      (select(dailyActions)..where((t) => t.id.equals(actionId))).getSingle();

  String _logId(String actionId) => 'log_$actionId';

  String? _normalizeNote(String? note) {
    final trimmed = note?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class JournalEntry {
  const JournalEntry({
    required this.log,
    required this.action,
    required this.note,
  });

  final ActionLog log;
  final DailyAction action;
  final String note;
}
