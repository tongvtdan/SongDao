Add a new Drift table to the SongDao local database.

**Usage:** `/add-table <TableName> [description of what it stores]`

Example: `/add-table UserSettings "User preferences: locale, selected church, reminder times"`

## What to do

1. Create `songdao/lib/data/local/tables/<snake_case_name>.dart` with a `@DataClassName` annotated Drift `Table` class. Follow the pattern in existing tables (`calendar_days.dart`, `daily_actions.dart`).

2. Add the table to `@DriftDatabase(tables: [...])` in `songdao/lib/data/local/app_database.dart`.

3. Run code generation:
   ```
   cd songdao && dart run build_runner build --delete-conflicting-outputs
   ```

4. If this is a schema migration (table added to existing DB), increment the `schemaVersion` in `AppDatabase` and add a `MigrationStrategy` step.

5. Create or update the Riverpod provider in `songdao/lib/data/local/database_provider.dart` to expose the new table's queries.

6. Report: table columns, primary key, any foreign keys, and which feature will use it.

Naming conventions:
- Table class: `PascalCase` (e.g., `UserSettings`)
- Dart file: `snake_case.dart` (e.g., `user_settings.dart`)
- Column names: `snake_case` (Drift convention)
- Always add `createdAt` and `updatedAt` timestamps unless the data is immutable (e.g., calendar days).

The argument provided by the user is: $ARGUMENTS
