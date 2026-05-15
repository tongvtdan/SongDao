# SongDao Current Status Report - 2026-05-09

## Insight

SongDao has crossed the important line from scaffold to usable local-first beta slice: the app has a Drift-backed Today loop, content-pack import, daily action generation, private completion/note logging, local reminders, basic parish/Mass logic, and an iOS WidgetKit bridge.

The highest-leverage issue is now content horizon and beta reliability, not architecture. The checked-in demo calendar pack ends on 2026-05-10, which means the app is one day away from relying on fallback behavior for real daily use. That weakens the core promise: "What should I do today to live my faith?"

## Review Inputs

- `.code-review-graph/graph.db`
- Flutter app under `songdao/lib`
- Symphony automation under `songdao/tool/symphony`
- iOS widget bridge under `songdao/ios`
- Content packs under `content/packs`
- Tests under `songdao/test`

Graph snapshot:

- Last updated: `2026-05-09T09:00:28`
- Branch: `feature/widget-notif`
- Head: `bffbd4b62ec024afdb69a4a61d31637929289c4c`
- Nodes: 746
- Edges: 1,227
- Files indexed: 68
- Languages: Dart, Swift, Kotlin, C, C++

Graph limitation: the risk index is not yet very useful. It assigns the same top score to platform/generated/app symbols and reports broad "untested" status, while actual domain coverage exists in `test/data/local/database_test.dart`. Treat the graph as a topology map, not a quality oracle.

## Current Status

Product surface:

- Today screen exists and owns the core loop: seed content, load calendar context, generate daily action, show readings, show important Mass, complete action, and save private note.
- Calendar, Prayer, Church Finder, Progress, and Settings screens exist.
- Bottom navigation follows the MVP map.
- User-facing UI is mostly Vietnamese by default.

Local-first foundation:

- Drift schema is at version 4 and includes calendar days, celebrations, readings, action rules, daily actions, action logs, user settings, widget snapshots, churches, Mass times, and prayers.
- Content pack import is transactional and checksum-verified.
- Reading validation blocks full text for `reference-only` and `pending-review` licenses.
- Action logs and notes are local database records.

Widget and reminders:

- Flutter generates compact widget snapshot JSON from local DB.
- iOS uses a custom MethodChannel and App Group `UserDefaults` bridge.
- WidgetKit small and medium layouts render graceful fallback copy when no snapshot exists.
- Local notification routing maps notification payloads back to Today.

Automation:

- `tool/symphony` is a credible local Linear-to-Codex daemon with config parsing, issue selection, workspace containment, JSON-RPC runner tests, retry tracking, and a small status API.
- It is isolated from app code, which is the right boundary.

Verification:

- `flutter analyze` passes.
- `flutter test` passes.
- One expected debug stack trace appears during `WidgetSnapshotBridge` failure-path testing; the test still passes because the bridge correctly returns a failure result instead of throwing.

## Findings

1. Content horizon is the main beta blocker.

   The default app asset imports only the 14-day demo calendar pack, and that pack is valid only through `2026-05-10`. See `content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json:7-8`, `songdao/pubspec.yaml:37-38`, and `songdao/lib/data/content/content_pack_provider.dart:7-19`.

   Impact: after 2026-05-10, Today still opens, but it degrades into fallback calendar/action behavior with no real readings or feast context. That directly harms activation and retention.

2. Parish beta data exists but is not bootstrapped into the app.

   The parish pack runs through tests and has a useful 2026 validity window, but it is not listed as a Flutter asset and is not imported by `seedContentBootstrapProvider`. See `content/packs/songdao-pack-parishes-vn-beta-2026-0.1.0.json:7-17`, `songdao/pubspec.yaml:37-38`, and `songdao/lib/data/content/content_pack_provider.dart:14-19`.

   Impact: Church Finder and Important Mass can work from the calendar demo pack, but the broader beta parish set is not part of the runtime bootstrap.

3. Today screen is carrying too much responsibility.

   `songdao/lib/features/today/today_screen.dart` is 862 lines and handles data loading, mutation, screen layout, copy, and multiple card components in one file. The critical load path is concentrated in `_loadToday` at `songdao/lib/features/today/today_screen.dart:38-84`.

   Impact: fine for a first slice, but the next product work will get slower unless data composition and UI cards are split before adding onboarding, richer notes, or completion history hooks.

4. Localization is only partially wired.

   ARB files currently cover tab labels only, while most product copy in Today and widget is hardcoded. See `songdao/lib/l10n/app_en.arb:1-8`, `songdao/lib/app/app.dart:31-33`, and the hardcoded Today copy beginning around `songdao/lib/features/today/today_screen.dart:131`.

   Impact: acceptable for Vietnamese-first beta, but weak for settings-driven locale support and future App Store polish.

5. Widget bridge needs real-device verification.

   The Dart bridge and Swift WidgetKit extension are logically aligned on channel name, app group ID, keys, and payload shape. See `songdao/lib/data/local/widget_snapshot_bridge.dart:9-29` and `songdao/ios/TodayWidget/TodayWidget.swift:4-120`.

   Impact: unit tests prove the Dart channel behavior, but not App Group entitlement/provisioning, WidgetKit reload behavior, or layout with actual Vietnamese payloads on device.

6. Content-pack validation is strong enough for demo, but not yet a content operations system.

   The importer validates required fields, dates, reading license constraints, Mass/church references, and checksum before import. See `songdao/lib/data/content/content_pack_importer.dart:38-91` and `songdao/lib/data/content/content_pack_importer.dart:119-196`.

   Impact: good trust posture. Next gap is coverage, provenance, and update workflow, not a new backend.

## Decision

Do not expand features yet. Ship a beta-readiness hardening slice centered on content horizon, runtime bootstrap, and widget/device confidence.

Recommended build target:

> By the end of the next 1-2 day slice, a beta user opening SongDao on any date in the next 30-60 days sees real Vietnamese liturgical context, one real daily action, safe reading references, and a working widget snapshot path.

## Execution: Next Steps

1. Extend the calendar content horizon.

   Create a `calendar-vn-beta-2026` pack covering at least the next 60 days from 2026-05-09, with safe reading references only. This is the top retention blocker.

2. Bootstrap multiple content packs.

   Update Flutter assets and `seedContentBootstrapProvider` to import the calendar beta pack plus parish beta pack idempotently. Keep checksum verification and transaction behavior unchanged.

3. Add content-pack regression tests.

   Add tests that prove:

   - default bootstrap imports all bundled packs
   - Today has non-fallback data after 2026-05-10
   - parish beta churches are available after bootstrap
   - widget snapshots regenerate after both content import and action completion

4. Split Today screen just enough.

   Extract a `TodayViewRepository` or `TodayController` for `_loadToday`, `_completeAction`, and `_saveNote`, then move card widgets into small files only if the diff stays low-risk. Do not introduce a broad architecture layer.

5. Verify iOS widget on simulator or device.

   Run the app, generate a snapshot, confirm App Group storage writes, confirm WidgetKit reload, and take small/medium widget screenshots with real Vietnamese text.

6. Move high-frequency copy into ARB.

   Prioritize Today, Settings, Church, and notification/widget fallback copy. Do not localize every internal string yet.

7. Use Symphony only after the product backlog is sharpened.

   Create small Linear tickets from this report, then let Symphony run one issue at a time. The daemon is ready enough; the bottleneck is high-quality issue scope.

## Suggested Linear Tickets

Linear issue title rule: prefix every new SongDao issue title with `SD-`, for example `SD-Improve today reading UI`.

1. `DAN`: `SD-Extend Vietnamese calendar beta content through 2026-07-31`
2. `DAN`: `SD-Import bundled calendar and parish packs during app bootstrap`
3. `DAN`: `SD-Add bootstrap regression tests for post-demo Today and parish data`
4. `DAN`: `SD-Verify iOS widget App Group bridge on simulator/device`
5. `DAN`: `SD-Extract Today data loading from Today screen`
6. `DAN`: `SD-Move Today and widget-facing copy into ARB localization`

## Bottom Line

The architecture is pointed in the right direction: local DB as source of truth, strict content packs, Today-first UX, widget snapshots, and private logs. The next winning move is not more surface area. It is making the daily loop survive past the demo content window and proving the widget on real iOS.
