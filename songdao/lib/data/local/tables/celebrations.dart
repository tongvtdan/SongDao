import 'package:drift/drift.dart';

// Referenced by the custom composite foreign key below.
// ignore: unused_import
import 'calendar_days.dart';

class Celebrations extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get name => text()();
  TextColumn get rank =>
      text()(); // solemnity | feast | memorial | optional_memorial | feria
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (date, locale) REFERENCES calendar_days (date, locale)',
  ];
}
