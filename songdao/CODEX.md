# CODEX.md

Codex should follow [AGENTS.md](AGENTS.md) first. This file keeps Codex aligned with the shared portfolio agent pattern.

## Project Memory

- Product: SongDao
- GitHub Project: `https://github.com/users/tongvtdan/projects/8`
- GitHub repository: `tongvtdan/SongDao`
- Stack: Flutter, Riverpod, GoRouter, Drift, local notifications, ARB localization
- Core trust surface: content packs, liturgical calendar data, local prayer/church usefulness

## Operating Loop

1. Define the user outcome and product-loop impact.
2. Surface assumptions around content rights, localization, local persistence, or reminders.
3. Choose the smallest shippable implementation.
4. Edit only files connected to the outcome.
5. Verify with the narrowest meaningful Flutter command or test.
6. Report changed behavior, verification, and residual risk.

## Guardrails

- Do not add new packages without clear need.
- Do not bypass content-pack validation.
- Do not put remote services in the daily loop unless explicitly required.
- Do not hardcode user-facing copy when localization is appropriate.
- Do not hand-edit generated Drift/localization files.

## GitHub Workflow

Work from Project #8. Move issues from `Ready` to `In progress` when starting, comment verification when complete, and move to `In review` rather than `Done`.
