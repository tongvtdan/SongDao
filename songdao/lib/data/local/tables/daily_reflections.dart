import 'package:drift/drift.dart';

// Referenced by the custom composite foreign key below.
// ignore: unused_import
import 'calendar_days.dart';

class DailyReflections extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get locale => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get license => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (date, locale) REFERENCES calendar_days (date, locale)',
  ];
}
