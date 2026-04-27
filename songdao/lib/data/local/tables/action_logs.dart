import 'package:drift/drift.dart';
import 'daily_actions.dart';

class ActionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get actionId => text().references(DailyActions, #id)();
  TextColumn get date => text()();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending | completed | skipped
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get selfCheckProofMetadata => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {actionId},
  ];
}
