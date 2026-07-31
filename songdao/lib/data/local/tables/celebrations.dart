import 'package:drift/drift.dart';
import 'calendar_days.dart';

class Celebrations extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().references(CalendarDays, #date)();
  TextColumn get name => text()();
  TextColumn get rank =>
      text()(); // solemnity | feast | memorial | optional_memorial | feria
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
