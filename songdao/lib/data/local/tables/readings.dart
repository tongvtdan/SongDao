import 'package:drift/drift.dart';
import 'calendar_days.dart';

class Readings extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().references(CalendarDays, #date)();
  TextColumn get type => text()(); // gospel | first | second | psalm | alleluia
  TextColumn get reference => text()(); // e.g. "Jn 3:16-21"
  TextColumn get title => text().nullable()();
  TextColumn get body => text()();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
