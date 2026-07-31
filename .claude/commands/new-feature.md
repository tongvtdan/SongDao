Scaffold a new Flutter feature screen for SongDao following the project's architecture.

**Usage:** `/new-feature <feature_name> [description]`

Example: `/new-feature settings "User settings and privacy controls"`

## What to do

1. Create `songdao/lib/features/<feature_name>/` directory with:
   - `<feature_name>_screen.dart` — main screen widget
   - `<feature_name>_provider.dart` — Riverpod provider(s) if data is needed

2. Add a route in `songdao/lib/app/router.dart` using the existing `go_router` pattern.

3. If a bottom nav tab is needed, update `songdao/lib/app/scaffold_with_nav_bar.dart`.

4. Follow these rules without exception:
   - Background: `AppColors.canvas` (#FAF8F3)
   - Cards: white with `Border.all(color: AppColors.borderSubtle)`, radius 8px
   - Primary action buttons: 48px height, `AppColors.brand` background
   - Text: `AppColors.textPrimary` / `AppColors.textSecondary`
   - Vietnamese text must wrap — never clip or overflow
   - Offline is a normal state, not an error

5. Start with a minimal working screen (no placeholder `// TODO` bodies), then report what data/tables it will need from Drift.

Read `songdao/lib/features/today/today_screen.dart` as the reference pattern before writing anything.

The argument provided by the user is: $ARGUMENTS
