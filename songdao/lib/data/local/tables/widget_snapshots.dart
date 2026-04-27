import 'package:drift/drift.dart';

class WidgetSnapshots extends Table {
  TextColumn get date => text()(); // YYYY-MM-DD, one snapshot per day
  TextColumn get payload => text()(); // JSON blob for iOS/Android widget
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};
}
