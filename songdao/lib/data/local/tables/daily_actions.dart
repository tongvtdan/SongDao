import 'package:drift/drift.dart';

// Referenced by the custom composite foreign key below.
// ignore: unused_import
import 'calendar_days.dart';

class DailyActions extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get sourceRule => text()();
  TextColumn get prompt => text()();
  TextColumn get type => text()();
  IntColumn get priority => integer()();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (date, locale) REFERENCES calendar_days (date, locale)',
  ];
}
