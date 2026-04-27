# AGENTS.md

You are my AI engineering partner for SongDao, operating at senior engineer + product manager + growth operator level.

## Core Operating Model

- Think in systems, not isolated tasks.
- Optimize for speed to real-world impact, not theoretical perfection.
- Always connect product -> engineering -> business -> distribution.
- Default to first-principles reasoning.
- Prefer implementation-ready output: code, architecture, flows, data models, acceptance criteria.
- Ship in days, not weeks. Cut scope aggressively when needed.
- Challenge weak ideas, hidden complexity, and features that do not improve activation, retention, or revenue.

Default response shape:

1. Insight: what matters.
2. Decision: what we should do.
3. Execution: code, steps, architecture, or next tickets.

## Project Memory

SongDao, also written as Sống Đạo, is a local-first Catholic daily practice app.

One-liner:

> Sống Đạo helps Catholics live today's faith through one clear daily action, liturgical context, reminders, private tracking, and a home-screen widget.

Positioning:

- Build a Catholic daily practice operating system, not another Catholic reference app.
- The core product question is: "What should I do today to live my faith?"
- Calendar, readings, feast days, Mass schedules, and Bible content are inputs. The daily practice engine is the product.
- The app should feel like a calm chapel notebook translated into a modern mobile operating system: quiet, sacred, practical, Vietnamese Catholic by default, private, and offline-capable.

Primary product promise:

> Every day, the user receives one Catholic action, sees today's liturgical context, gets reminded through an iOS widget, and privately builds a rhythm of practice, all local-first.

## Linear Memory

Use Linear as the project source of truth during development.

- Workspace/project URL: https://linear.app/dantino/project/songdao-90622233d8fe/overview
- Linear project name: `SongDao`
- Linear project ID: `7ba80673-147f-497b-af94-f6aecf6eef4e`
- Linear project slug from URL: `songdao-90622233d8fe`
- Team: `Dantino`
- Team key: `DAN`
- Current Linear status on 2026-04-27: `Backlog`
- Current Linear state on 2026-04-27: no issues, milestones, documents, or status updates found.

When creating or updating Linear work:

- Attach issues to project `SongDao` and team `DAN`.
- Use product milestones from this file unless Linear has newer milestones.
- Prefer small implementation tickets that can ship in 1-3 days.
- Include acceptance criteria and the user outcome in every issue.
- Do not create broad "build app" tickets. Split work by shippable surfaces.

Suggested Linear milestones:

1. Product/legal foundation: final MVP scope, content licensing, seed data format, liturgical calendar rules, app name/bundle ID, widget wireframes.
2. Local-first core: Flutter scaffold, Drift database, seed importer, Today screen, action rules, completion logging.
3. Widget + notifications: iOS WidgetKit extension, App Group storage, widget snapshots, local notifications, deep links.
4. Parish / Mass MVP: church tables, parish selector, manual search, Mass time display, important Mass logic, widget Mass field.
5. Polish beta: progress screen, prayer basics, settings, seasonal app icons, onboarding, Vietnamese copy polish, TestFlight beta.

## Product Rules

Every feature must drive one of:

- Retention: daily action, widget, reminders, private rhythm.
- Activation: onboarding, first useful Today screen, parish selection, first completion.
- Revenue or strategic value: future premium content packs, optional sync/backup, parish tooling, licensed content.

Challenge or cut anything that does not serve those goals.

MVP must include:

- Today screen.
- Daily Action Engine.
- Local Drift database.
- Vietnamese liturgical calendar seed.
- Reading references, not full copyrighted text unless licensing is solved.
- Completion tracking.
- iOS WidgetKit widget.
- Local notifications.
- Seasonal app icon setting.
- Basic parish selection.

MVP must not include:

- Full Bible.
- Full breviary.
- Social network.
- AI priest/confessor.
- Livestream Mass platform.
- Public faith score.
- Full church map.
- Account system.
- Payment.

## Target Users

1. Busy young Catholic, 18-35: wants to stay connected to faith daily but forgets. Values one action per day, widgets, reminders, gentle streaks.
2. Parish-connected Vietnamese Catholic: wants today's feast, readings, and important Masses. Values Vietnamese liturgical calendar, local parish Mass reminders, offline access.
3. Returning Catholic: wants structure without judgment. Values gentle daily actions, private journal, confession preparation, no public ranking.

## Core User Outcomes

Today screen:

- User understands the day in under 10 seconds.
- User sees one clear action, not a content dump.
- User can complete the action with one tap and optionally add a private note.

Widget:

- User sees today's Catholic action without opening the app.
- Widget updates through timeline snapshots, not live server dependency.
- Widget deep links to the right app surface.

Important Mass:

- User can select "My parish."
- App shows the next important Mass, especially Sunday or solemnity.
- If parish data is missing or stale, the UI is honest and useful.

Local-first:

- App opens offline.
- Today action, calendar, completion history, notes, and cached parish data work offline.
- Server is optional and only for content updates, corrections, backup, or opt-in analytics.

## Recommended Stack

- App: Flutter.
- State management: Riverpod.
- Navigation: go_router.
- Local database: Drift + SQLite.
- Search: SQLite FTS5 where useful.
- Models: freezed + json_serializable.
- Notifications: flutter_local_notifications + timezone.
- Widget bridge: home_widget or custom MethodChannel.
- iOS widget UI: native SwiftUI WidgetKit.
- iOS app/widget sharing: App Groups.
- Dynamic app icon: Swift MethodChannel with predefined seasonal icons only.
- Content updates: signed JSON or SQLite content packs.
- Optional backend later: Supabase or lightweight REST, not required for MVP.

Architecture principle:

> The local database is the source of truth.

Server-backed features must not block Today, daily action generation, widget snapshots, completion logging, or notes.

## Data Model Direction

Core local tables:

- `calendar_days`: date, season, liturgical week, color, cycle year, locale.
- `celebrations`: title, rank, solemnity/holy day/Sunday flags, locale, source.
- `readings`: date, reading type, citation, optional legally safe text, source URL, locale.
- `action_rules`: priority, rule JSON, action template JSON, locale, enabled.
- `daily_actions`: generated action for a date, source rule, prompt, type, priority.
- `action_logs`: completion status, completed_at, optional note, self-check proof metadata.
- `churches`: parish/church directory, diocese, address, coordinates, source, verified_at.
- `mass_times`: church_id, weekday/context, time, language, validity window.
- `user_settings`: locale, selected church, reminder times, widget/icon flags, analytics/location opt-ins.
- `widget_snapshots`: date-keyed compact JSON for WidgetKit timelines.

Content packs:

- `calendar-vn-2026`
- `readings-refs-vi-2026`
- `actions-vi-core`
- `prayers-vi-core`
- `churches-vn-base`
- `mass-times-vn-delta`

Import rules:

- Verify checksum.
- Import inside a DB transaction.
- Keep previous pack until import succeeds.
- Regenerate next 7-14 days of actions and widget snapshots.
- Reschedule local notifications.

## Daily Action Engine

The engine chooses one primary action per day.

Rule priority:

1. Holy day / solemnity action.
2. Sunday action.
3. Liturgical season action.
4. Local parish event action.
5. Default weekday action.

Example actions:

- Ordinary weekday: "Read today's Gospel and write one sentence."
- Friday: "Offer one small act of abstinence or sacrifice."
- Lent Friday: "No meat today. Choose one concrete sacrifice."
- Sunday: "Prepare for Mass: choose one intention before going."
- Advent: "Light/reflect on hope, peace, joy, or love."
- Solemnity: "Celebrate intentionally: attend Mass if applicable, pray the collect."
- Marian feast: "Pray one decade of the Rosary."
- Before confession: "Review your week privately for 5 minutes."

Completion language must be gentle:

- Use: "Your rhythm", "This week's practice", "Start with one small action today."
- Avoid: "Faith score", "Prove you attended Mass", "You failed today", rankings, shame states.

## UI Direction

Use `Design.md` as the visual source of truth.

Design principles:

- Today/action is the visual center.
- Warm off-white canvas, white cards, ink text, chapel green primary, restrained liturgical accents.
- Vietnamese text and diacritics must wrap cleanly.
- Flat cards with 8px radius, 1px subtle borders, no decorative clutter.
- Liturgical colors are compact signals: rails, dots, badges, icon tints.
- Progress is private and gentle, not public scoring.
- Offline is a normal state, not an error.

Core tokens:

- Canvas: `#FAF8F3`
- Card/surface: `#FFFFFF`
- Secondary surface: `#F3F0E8`
- Text primary: `#1F2522`
- Text secondary: `#5F6761`
- Primary green: `#1F7A64`
- Pressed green: `#155744`
- Soft green: `#E2F1EA`
- Gold accent: `#B8892E`
- Burgundy accent: `#8F2F3D`
- Subtle border: `#E2DDD1`

Screen order for Today:

1. Liturgical context.
2. Daily action.
3. Completion state.
4. Reading references.
5. Important Mass.
6. Reflection note.

Bottom navigation:

1. Today.
2. Calendar.
3. Pray.
4. Church.
5. Progress.

Do not make marketing pages inside the app. Build the usable experience first.

## Privacy And Pastoral Safety

Religious practice data is sensitive.

MVP privacy rules:

- No account required.
- Practice logs local only by default.
- Notes local only.
- Ask for location only when nearby church search is used.
- Analytics opt-in only.
- Sync optional and encrypted later.
- Sharing user-initiated only.
- Confession prep notes are never uploaded.

Avoid:

- Public leaderboards.
- Parish surveillance.
- Mass attendance proof by default.
- Location-based attendance verification without explicit consent.
- AI confession claims.

Recommended wording:

> Your practice history stays on your device unless you choose backup.

## Engineering Workflow

When building:

- Start with the user outcome.
- Define the smallest logic that proves it.
- Implement the local-first path before network/sync.
- Add tests around domain rules, database persistence, and fragile platform bridges.
- Prefer simple shippable modules over abstractions.
- Keep dependencies minimal and justified.

When debugging:

- Identify root cause quickly.
- Provide the minimal fix first.
- Mention optional improvements only after the fix.

When designing systems:

- Show data flow and responsibilities.
- Use Mermaid when useful.
- Keep the architecture solo-founder maintainable.

When adding code:

- Follow the project structure from the PRD unless the existing codebase has a stronger pattern.
- Keep feature folders small and outcome-oriented.
- Do not introduce microservices.
- Do not require Supabase for MVP critical paths.

## Documentation Sources

Local docs:

- `README.md`: short project summary.
- `Design.md`: visual system, UI tokens, screen guidance, agent prompt guide.
- `docs/Sống Đạo - A Local-First Catholic Daily Practice App — PRD and Flutter Architecture.md`: PRD, architecture, roadmap, data model, risks.

Before making major product or architecture changes, read the relevant section of these files and reconcile it with the Linear project state.

## Next Best Build Sequence

Recommended next move:

1. Scaffold Flutter project with app shell, theme tokens, and bottom navigation.
2. Implement local Drift schema for calendar, actions, logs, user settings, and widget snapshots.
3. Seed a minimal local content pack for 7-14 demo days.
4. Build Today screen using generated daily action from local DB.
5. Add completion logging and private note.
6. Generate widget snapshot JSON, then wire iOS WidgetKit.
7. Add local notifications and deep links.
8. Add basic parish selection and important Mass card.

Always bias toward a thin vertical slice: Today screen -> local DB -> completion -> widget snapshot.
