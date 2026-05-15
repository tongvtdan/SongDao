import 'package:drift/drift.dart';

import 'churches.dart';

class MassTimes extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get weekday => text()();
  TextColumn get context => text()();
  TextColumn get time => text()();
  TextColumn get language => text()();
  DateTimeColumn get validFrom => dateTime()();
  DateTimeColumn get validTo => dateTime().nullable()();
  BoolColumn get isImportantDefault =>
      boolean().withDefault(const Constant(false))();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
