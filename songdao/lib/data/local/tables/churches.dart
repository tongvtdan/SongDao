import 'package:drift/drift.dart';

@DataClassName('Church')
class Churches extends Table {
  TextColumn get id => text()();
  TextColumn get locale => text()();
  TextColumn get name => text()();
  TextColumn get diocese => text()();
  TextColumn get address => text()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get source => text()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
