import 'package:drift/drift.dart';
import 'daily_actions.dart';

class ActionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get actionId => text().references(DailyActions, #id)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get selfCheckProofMetadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
