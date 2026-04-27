// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_dao.dart';

// ignore_for_file: type=lint
mixin _$TodayDaoMixin on DatabaseAccessor<AppDatabase> {
  $CalendarDaysTable get calendarDays => attachedDatabase.calendarDays;
  $DailyActionsTable get dailyActions => attachedDatabase.dailyActions;
  $ActionLogsTable get actionLogs => attachedDatabase.actionLogs;
  $WidgetSnapshotsTable get widgetSnapshots => attachedDatabase.widgetSnapshots;
  TodayDaoManager get managers => TodayDaoManager(this);
}

class TodayDaoManager {
  final _$TodayDaoMixin _db;
  TodayDaoManager(this._db);
  $$CalendarDaysTableTableManager get calendarDays =>
      $$CalendarDaysTableTableManager(_db.attachedDatabase, _db.calendarDays);
  $$DailyActionsTableTableManager get dailyActions =>
      $$DailyActionsTableTableManager(_db.attachedDatabase, _db.dailyActions);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db.attachedDatabase, _db.actionLogs);
  $$WidgetSnapshotsTableTableManager get widgetSnapshots =>
      $$WidgetSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.widgetSnapshots,
      );
}
