import 'package:drift/drift.dart';

class Prayers extends Table {
  TextColumn get id => text()();
  TextColumn get locale => text()();
  TextColumn get title => text()();
  TextColumn get body => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get license => text()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
