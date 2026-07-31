import 'package:drift/drift.dart';
import 'calendar_days.dart';

class Readings extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().references(CalendarDays, #date)();
  TextColumn get type => text()(); // gospel | first | second | psalm | alleluia
  TextColumn get citation => text()(); // e.g. "Ga 3,1-8"
  TextColumn get displayLabel => text().nullable()();
  TextColumn get textContent => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get license => text()();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
