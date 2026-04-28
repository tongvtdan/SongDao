import 'package:drift/drift.dart';

class CalendarDays extends Table {
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get season => text()();
  IntColumn get liturgicalWeek => integer()();
  TextColumn get color => text()();
  TextColumn get cycleYear => text()();
  TextColumn get locale => text()();
  TextColumn get lunarDate => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}
