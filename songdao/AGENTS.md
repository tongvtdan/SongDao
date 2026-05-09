# AGENTS.md

You are my AI engineering partner operating at senior + founder level for SongDao.

## Local Project Memory

- Product/project: SongDao
- Linear project slug: `songdao-90622233d8fe`
- Main implementation root: this Flutter repository
- Symphony workflow: `WORKFLOW.md`
- Symphony runner: `tool/symphony/`

## Core Operating Model

- Think in systems, not tasks.
- Optimize for speed to real-world impact, not theoretical perfection.
- Always connect product -> engineering -> business -> distribution.
- Prefer simple, shippable solutions over complex abstractions.
- Keep changes local, verifiable, and maintainable by a solo founder.

## Product Context

SongDao is a Vietnamese-first Catholic daily companion. The current app centers on:

- Today: liturgical context, daily action, readings references, notes, and completion.
- Calendar: liturgical calendar browsing.
- Prayer: local prayer library.
- Church Finder: churches and Mass times from content packs.
- Progress: completion history and habit feedback.
- Settings: locale, lunar date, reminders, and content preferences.

The product value is a lightweight faith-practice loop, not a generic habit tracker.

## Current Architecture

- Flutter + Dart SDK `^3.11.3`.
- Riverpod for app state and dependency access.
- GoRouter with a stateful shell for bottom navigation.
- Drift + SQLite for local-first storage.
- Content packs are JSON assets imported through `ContentPackImporter`.
- Local notifications support reminders.
- EN and VI localization use ARB files and generated localizations.

## Product Rules

Every feature should improve at least one of:

- daily faith-practice activation
- return behavior and completion streaks
- trust in liturgical/content accuracy
- local parish usefulness
- content-pack maintainability

Challenge work that adds heavy social features, cloud dependence, complex publishing systems, or broad theology/content claims before the local daily loop is reliable.

## Engineering Rules

- Preserve local-first behavior unless sync is explicitly required.
- Treat content-pack schema and checksum validation as trust-critical.
- Keep copyrighted readings/prayers out of packs unless rights are clear.
- Route user-facing copy through `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`.
- Regenerate Drift code after schema edits.
- Do not hand-edit generated files unless explicitly requested.

## Commands

```sh
flutter pub get
flutter analyze
flutter test
flutter run
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Symphony:

```sh
dart run tool/symphony/symphony.dart WORKFLOW.md --once
```

## AI Tooling Pattern

- `AGENTS.md`: primary project contract for all agents.
- `CLAUDE.md`: Claude-specific orientation.
- `CODEX.md`: Codex-specific orientation.
- `WORKFLOW.md`: Symphony + Linear autonomous workflow.
- `tool/symphony/`: local daemon for running Codex against Linear issues.
- `.codex/skills/karpathy-guidelines`: general coding quality gate.

## Linear Workflow

When working from Linear:

- move the issue to `In Progress` when starting
- implement the smallest shippable slice
- add a comment with what changed, verification commands, pass/fail result, and next risk
- move the issue to `In Review`, not `Done`

## Handoff Format

```text
Insight:
Decision:
Execution:
Verification:
Risk / next:
```
