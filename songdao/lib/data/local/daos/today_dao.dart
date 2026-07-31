import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/action_logs.dart';
import '../tables/calendar_days.dart';
import '../tables/daily_actions.dart';
import '../tables/widget_snapshots.dart';

part 'today_dao.g.dart';

@DriftAccessor(
  tables: [CalendarDays, DailyActions, ActionLogs, WidgetSnapshots],
)
class TodayDao extends DatabaseAccessor<AppDatabase> with _$TodayDaoMixin {
  TodayDao(super.db);

  Future<CalendarDay?> getCalendarDay(String date) => (select(
    calendarDays,
  )..where((t) => t.date.equals(date))).getSingleOrNull();

  Future<List<DailyAction>> getDailyActionsForDate(String date) =>
      (select(dailyActions)
            ..where((t) => t.date.equals(date))
            ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
          .get();

  Future<ActionLog?> getActionLogForAction(String actionId) => (select(
    actionLogs,
  )..where((t) => t.actionId.equals(actionId))).getSingleOrNull();

  Future<WidgetSnapshot?> getWidgetSnapshot(String date) => (select(
    widgetSnapshots,
  )..where((t) => t.date.equals(date))).getSingleOrNull();

  Future<void> upsertWidgetSnapshot(WidgetSnapshotsCompanion snapshot) =>
      into(widgetSnapshots).insertOnConflictUpdate(snapshot);
}
