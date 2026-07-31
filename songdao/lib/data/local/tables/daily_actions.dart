import 'package:drift/drift.dart';
import 'calendar_days.dart';

class DailyActions extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().references(CalendarDays, #date)();
  TextColumn get sourceRule => text()();
  TextColumn get prompt => text()();
  TextColumn get type => text()();
  IntColumn get priority => integer()();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
