// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_log_dao.dart';

// ignore_for_file: type=lint
mixin _$ActionLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $CalendarDaysTable get calendarDays => attachedDatabase.calendarDays;
  $DailyActionsTable get dailyActions => attachedDatabase.dailyActions;
  $ActionLogsTable get actionLogs => attachedDatabase.actionLogs;
  ActionLogDaoManager get managers => ActionLogDaoManager(this);
}

class ActionLogDaoManager {
  final _$ActionLogDaoMixin _db;
  ActionLogDaoManager(this._db);
  $$CalendarDaysTableTableManager get calendarDays =>
      $$CalendarDaysTableTableManager(_db.attachedDatabase, _db.calendarDays);
  $$DailyActionsTableTableManager get dailyActions =>
      $$DailyActionsTableTableManager(_db.attachedDatabase, _db.dailyActions);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db.attachedDatabase, _db.actionLogs);
}
