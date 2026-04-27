Validate the current Flutter UI code against the Sống Đạo design system (Design.md).

**Usage:** `/check-design [file_or_feature_path]`

Example: `/check-design songdao/lib/features/today/today_screen.dart`
Example: `/check-design` (reviews all feature screens)

## What to do

1. Read `Design.md` at the project root first.
2. Read the target file(s) — if no argument, check all files under `songdao/lib/features/`.
3. Review against these non-negotiable rules:

**Colors — must use AppColors tokens, never hardcoded hex:**
- Background: `AppColors.canvas`
- Cards: `Colors.white` with `AppColors.borderSubtle` border
- Primary: `AppColors.brand`
- Text: `AppColors.textPrimary` / `AppColors.textSecondary`

**Cards:**
- Radius exactly 8px (`BorderRadius.circular(8)`)
- 1px border with `AppColors.borderSubtle`
- No shadow by default

**Buttons:**
- Primary: 48px height minimum, `AppColors.brand` background
- Secondary: 44px height, white background with border

**Today screen section order:**
1. Liturgical context
2. Daily action card (visually dominant)
3. Completion state
4. Reading references
5. Important Mass
6. Reflection note

**Copy rules:**
- No "faith score", "failed", "prove", rankings, or shame language
- Vietnamese text must wrap cleanly — no `overflow: TextOverflow.clip` unless intentional

**Offline:**
- Never show network error for missing server data
- Always show cached state with neutral offline chip

4. Output a numbered list: **Issue | File:Line | Fix**. If nothing is wrong, say "Design system: no violations found."

The argument provided by the user is: $ARGUMENTS
