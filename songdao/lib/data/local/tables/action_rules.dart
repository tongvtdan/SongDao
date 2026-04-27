import 'package:drift/drift.dart';

class ActionRules extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get triggerCondition => text()(); // JSON condition string
  TextColumn get templatePrompt => text()();
  IntColumn get priority => integer()();
  TextColumn get locale => text().nullable()();
  TextColumn get packId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
