import 'package:drift/drift.dart';

class UserEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get calendarSystem => text()();
  IntColumn get anchorYear => integer()();
  IntColumn get anchorMonth => integer()();
  IntColumn get anchorDay => integer()();
  BoolColumn get isLeapMonth => boolean().withDefault(const Constant(false))();
  TextColumn get recurrence => text()();
  IntColumn get eventHour => integer().nullable()();
  IntColumn get eventMinute => integer().nullable()();
  IntColumn get reminderOffsetMinutes => integer().nullable()();
  TextColumn get color => text().withDefault(const Constant('burgundy'))();

  // Kept for v8 database compatibility. New writes use reminderOffsetMinutes.
  IntColumn get reminderOffsetDays => integer().nullable()();
  IntColumn get reminderHour => integer().nullable()();
  IntColumn get reminderMinute => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
