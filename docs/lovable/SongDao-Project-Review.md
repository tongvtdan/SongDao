# Sống Đạo Project Review For Lovable

## Insight

Sống Đạo is already past the idea stage. The repo contains a serious local-first Flutter implementation and a functioning Next/PWA prototype. The highest-leverage move for Lovable is not "start over." It is to use Lovable to produce a polished, web-first MVP that validates the daily practice loop with the updated Open Design theme.

## Decision

Use Lovable for a local-first PWA:

> Today -> one action -> completion -> note -> private rhythm -> parish context

Do not use Lovable to rebuild the native Flutter architecture, iOS WidgetKit, Drift schema, or platform bridges yet. Those are native-product concerns. Lovable should validate activation, visual direction, and distribution.

## Current Repo Review

### Flutter App

Location:

`/Users/dantong/Projects/Mobile-Apps/SongDao/songdao`

What matters:

- Local-first architecture is already correct.
- Drift schema covers calendar days, celebrations, readings, action rules, daily actions, logs, settings, churches, Mass times, prayers, reflections, and widget snapshots.
- Content pack importer exists.
- Today screen, completion logging, notification service, widget bridge, settings, progress, calendar, prayer, and church screens exist.
- This is the right eventual native app foundation.

Risk:

- Native app complexity is higher than Lovable needs.
- Do not make Lovable reproduce platform-specific widget/App Group code.

### Current Webapp

Location:

`/Users/dantong/Projects/Mobile-Apps/SongDao/songdao-web`

What matters:

- Functional PWA prototype already exists.
- It has date-based Today routing, localStorage logs/notes/settings, content pack loading, action engine, progress view, calendar, prayer, settings, and desktop dashboard.
- Browser check on `http://localhost:3000/today/2026-05-29` confirmed the core content renders with no horizontal overflow at the tested desktop viewport.

Design issue:

- Current webapp still reads more like the older green chapel dashboard.
- The updated Open Design export is warmer, more editorial, more terracotta, more paper-like, and more route/screen-first.

### Updated Theme Reference

Location:

`/Users/dantong/Projects/Mobile-Apps/SongDao/graphics-design/Song-Dao-Open-Design`

Use this as the active Lovable visual contract.

Important files:

- `DESIGN-HANDOFF.md`
- `DESIGN-MANIFEST.json`
- `songdao.css`
- `landing.html`
- `today.html`
- `practice.html`
- `calendar.html`
- `parish.html`
- `progress.html`

Core design direction:

- Warm paper UI, not green dashboard.
- `#f5f4ed` background.
- `#faf9f5` surface.
- `#e8e6dc` warm surface.
- `#141413` ink text.
- `#c96442` terracotta accent.
- Serif display typography.
- Thin borders, calm cards, minimal shadow.
- Landing page and app screens are separate.

## Product Review

The product thesis is strong:

> The daily action engine is the product. Calendar, readings, feast days, Mass schedules, and prayers are inputs.

This is the right positioning because it avoids three traps:

- Competing with larger Catholic content libraries.
- Getting stuck in Bible/lectionary licensing before proving retention.
- Becoming a generic habit tracker with religious labels.

## Engineering Review

The best Lovable architecture is intentionally simpler than the Flutter app:

- React + TypeScript
- Local seed data
- Deterministic action engine
- localStorage persistence
- Optional Supabase later

Core domain logic should be plain TypeScript:

- `selectDailyAction`
- `getTodayView`
- `markCompleted`
- `saveNote`
- `getWeekProgress`
- `selectNextImportantMass`

React components should render view models, not contain rule logic.

## Business / Distribution Review

Lovable should produce a shareable web MVP that can be used for:

- Waitlist and early user testing.
- Parish/family demos.
- App Store screenshot direction.
- Validating whether users complete actions and return.
- Testing copy and design before native polish.

Future monetization should not be in MVP. Later paid surfaces can be:

- Seasonal guided packs.
- Family/household practice plans.
- Optional encrypted backup/sync.
- Parish tooling or verified Mass-time updates.
- Licensed content packs.

## Build Priority

1. Today route with seeded date content.
2. Daily Action Engine.
3. Completion + note local persistence.
4. Private Progress.
5. Calendar navigation.
6. Parish selector + Important Mass.
7. Pray library.
8. Settings backup/import.
9. Landing page polish.

## Cut List

Cut from Lovable MVP:

- Accounts
- Payment
- Supabase auth
- AI features
- Full Bible text
- Full breviary
- Social sharing by default
- Maps
- Native widget implementation
- Attendance proof

## Bottom Line

Build the Lovable app as a beautiful, local-first validation layer. Keep the native Flutter app as the deeper platform path. The bridge between them is the product loop and content/action model, not identical code.

