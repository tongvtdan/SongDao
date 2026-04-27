Run Dart build_runner code generation for SongDao (Drift + any other build_runner targets).

**Usage:** `/gen-code`

## What to do

Run the following in the Flutter project root:

```bash
cd /Users/dantong/Projects/Mobile-Apps/SongDao/songdao
dart run build_runner build --delete-conflicting-outputs
```

Then check for errors:
- If `app_database.g.dart` was regenerated successfully, confirm the table count matches `app_database.dart`.
- If there are errors, show the full error message and identify which table or annotation caused it.
- After success, run `flutter analyze` to catch any type mismatches introduced by the new generated code.

Common issues:
- Missing `part 'filename.g.dart';` directive in a table file → add it
- `@DriftDatabase` tables list out of sync with actual table files → reconcile
- `schemaVersion` not incremented after adding a table → bump it and add migration

Report the result: how many tables are now in the schema, and whether analyze passed.
