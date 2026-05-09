# CLAUDE.md

Claude Code should follow [AGENTS.md](AGENTS.md) as the project contract. This file adds Claude-specific orientation for SongDao.

## Project

- Product: SongDao
- Linear project slug: `songdao-90622233d8fe`
- App type: Flutter local-first Catholic daily companion

## Claude Rules

- Start from the user outcome and the faith-practice loop.
- Keep app changes small and consistent with nearby Flutter code.
- Preserve content-pack schema integrity and checksum behavior.
- Avoid copyrighted full-text content unless rights are explicit.
- Keep EN and VI localization in sync.

## Commands

```sh
flutter pub get
flutter analyze
flutter test
flutter run
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## Handoff Format

```text
Insight:
Decision:
Execution:
Verification:
Risk / next:
```
