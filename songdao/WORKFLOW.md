---
tracker:
  kind: github
  token: "$GITHUB_TOKEN"
  owner: "tongvtdan"
  project_number: 8
  repository: "tongvtdan/SongDao"
  status_field: "Status"
  priority_field: "Priority"
  active_states:
    - Ready
    - In progress
  terminal_states:
    - Done
polling:
  interval_ms: 30000
workspace:
  root: ".symphony/workspaces"
hooks:
  after_create: |
    git clone --origin origin https://github.com/tongvtdan/SongDao.git .
  before_run: |
    git remote get-url origin
    git status --short
  after_run: |
    true
  before_remove: |
    true
  timeout_ms: 120000
agent:
  max_concurrent_agents: 1
  max_turns: 8
  max_retry_backoff_ms: 300000
  max_concurrent_agents_by_state:
    Ready: 1
    In progress: 1
codex:
  command: "codex app-server"
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000
server:
  port: 0
---
# SongDao Symphony Workflow

You are an autonomous implementation agent working on SongDao from a GitHub issue in [Project #8](https://github.com/users/tongvtdan/projects/8) and the [tongvtdan/SongDao](https://github.com/tongvtdan/SongDao) repository.

Issue: {{ issue.identifier }}
Title: {{ issue.title }}
State: {{ issue.state }}
Priority: {{ issue.priority }}
Labels: {{ issue.labels }}
URL: {{ issue.url }}

Description:
{{ issue.description }}

## Product North Star

SongDao helps Vietnamese Catholic users practice daily faith with liturgical context, one clear daily action, prayer support, parish/Mass usefulness, and lightweight progress.

Every task must improve at least one of:

- Daily faith-practice activation.
- Return behavior and completion consistency.
- Trust in calendar, readings references, prayers, churches, or Mass times.
- Content-pack maintainability.
- Local-first reliability.

If the issue does not clearly improve one of those, stop and add a GitHub issue comment explaining the concern.

## Current Ship Path

```text
content pack -> Today screen -> daily action completion -> reminder/progress loop -> parish/prayer usefulness
```

Keep work focused on local content reliability, Today, Calendar, Prayer, Church Finder, Progress, reminders, and localization.

## GitHub Project Policy

Use the GitHub issue number as the identifier. Write outcome-focused titles without a manual `SD-` prefix, add the issue to [Song Dao Project #8](https://github.com/users/tongvtdan/projects/8), and keep work in [tongvtdan/SongDao](https://github.com/tongvtdan/SongDao).

1. Move `Ready` issues to `In progress` before editing.
2. Work in the smallest shippable slice that satisfies acceptance criteria.
3. Add a GitHub issue comment with what changed, verification commands, pass/fail result, and follow-up risk.
4. Move completed implementation to `In review`, not `Done`. Use `Done` only after review and merge.

## Engineering Rules

- Preserve local-first behavior.
- Keep content-pack checksum and schema validation strict.
- Avoid copyrighted full-text readings/prayers unless rights are explicit.
- Route user-facing copy through ARB localization files.
- Do not hand-edit generated Drift or localization files.

## Verification Ladder

Default full check:

```sh
flutter analyze
flutter test
```

Content-pack/database check:

```sh
flutter test test/data/local/database_test.dart
```

Symphony check:

```sh
flutter test test/symphony/symphony_test.dart
```

After Drift schema changes:

```sh
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Handoff Format

```text
Insight:
Decision:
Execution:
Verification:
Risk / next:
```
