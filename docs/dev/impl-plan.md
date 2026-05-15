Update SongDao UI to Sacred Harmony Design System
This plan outlines the steps to translate the "Sacred Harmony" design system (described in DESIGN.md and HTML mockups) into the Flutter codebase for the SongDao app.

User Review Required
IMPORTANT

Adding a new dependency google_fonts to pubspec.yaml to load Noto Serif and Inter. Is this acceptable? If you prefer bundling the fonts locally to ensure offline capabilities, let me know.
Material 3 NavigationBar will be used instead of BottomNavigationBar to achieve the selected "pill" background effect from the design without building a fully custom bottom nav from scratch. Please let me know if you strongly prefer a custom widget.
Proposed Changes
Configuration
[MODIFY] pubspec.yaml
Add google_fonts: ^6.2.1 to dependencies to fetch "Noto Serif" and "Inter" easily. (Or we can download them locally if strictly offline is required, but google_fonts caches them after first fetch).
App Theming
[MODIFY] lib/app/theme.dart
Overhaul AppColors to match DESIGN.md:
canvas (background): #FCF9F3
surface (lowest): #FFFFFF
surfaceSecondary (low): #F6F3ED
primary: #204E2B
secondary: #6E5097
tertiary: #841D24
Update liturgicalColor mapped values to use the new muted palette where appropriate.
Update AppTheme.lightTheme:
Integrate GoogleFonts.notoSerifTextTheme for display/headline.
Integrate GoogleFonts.interTextTheme for body/label.
Update CardTheme to have subtle shadows and 16px border radius (or 8px/12px based on component).
Update NavigationBarTheme for the new bottom nav.
[MODIFY] lib/app/scaffold_with_nav_bar.dart
Replace BottomNavigationBar with Material 3 NavigationBar to match the visual style of the HTML nav (pill-shaped selection, specific font sizes).
Today Screen
[MODIFY] lib/features/today/today_screen.dart
Redesign _LiturgicalContextCard to have the background texture/image and the large typography (Lunar Date, Month/Year Pill, and Liturgical Tags) as seen in today_screen_block_calendar/code.html.
Redesign _DailyActionCard (Hy sinh hôm nay) to have the left-accented colored border, updated icons, and the full-width primary button.
Refactor the "Bento Layout" grid for _ReadingReferencesCard and _ImportantMassCard so they sit side-by-side on larger screens, or mimic the border and spacing of the HTML.
Add the Daily Quote / Inspiration section at the bottom of the screen.
Verification Plan
Automated Tests
Run flutter analyze to ensure no syntax errors.
Run flutter test if any widget tests exist.
Manual Verification
Launch the app locally.
Verify that the fonts load correctly.
Verify the "Today" screen matches the layout and color palette of code.html.
Verify the bottom navigation looks correct and handles state transitions properly.

Update SongDao UI & Add Lunar Date Toggle
 Update pubspec.yaml to include google_fonts: ^6.2.1.
 Run flutter pub get to download the packages.
 Overhaul lib/app/theme.dart with the new colors, Google Fonts, and updated CardTheme.
 Update lib/app/scaffold_with_nav_bar.dart to use NavigationBar.
 Create lib/features/settings/settings_screen.dart for the lunar date toggle setting.
 Add the settings screen route to lib/app/router.dart.
 Implement UserSettingsDao or similar mechanism to read/write settings if not already fully implemented.
 Redesign lib/features/today/today_screen.dart with the new bento UI layout, Sacred Harmony styling, and Lunar Date conditional rendering.
 Run flutter analyze to ensure code correctness.
 