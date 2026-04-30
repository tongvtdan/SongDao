# Symphony Service

Symphony is a local automation daemon for running Codex against Linear issues.
It is intentionally isolated under `tool/symphony` so the SongDao Flutter app
code stays focused on the mobile product.

## Run

```sh
dart run tool/symphony/symphony.dart path/to/WORKFLOW.md --once
```

For daemon mode:

```sh
dart run tool/symphony/symphony.dart path/to/WORKFLOW.md --port=0
```

The optional local status server exposes:

- `GET /`
- `GET /api/v1/state`
- `GET /api/v1/<issue_identifier>`
- `POST /api/v1/refresh`

## Trust Posture

The first implementation is a trusted local daemon. It is designed for a solo
operator running against known repositories and known Linear projects.

Current controls:

- Linear API tokens are read from config/env and never logged.
- Codex is launched only with `cwd` equal to the per-issue workspace.
- Workspace paths are sanitized from issue identifiers.
- Workspace paths must stay under `workspace.root`.
- Hook scripts are trusted repo configuration.
- Hook scripts run in the per-issue workspace and have timeouts.
- User-input-required or unsupported dynamic tool behavior must not stall a run;
  unsupported output is treated as structured runtime failure by the runner layer.

Not included in the first pass:

- VM/container isolation.
- Durable scheduler database.
- Remote SSH worker pool.
- First-class Linear mutations in the orchestrator.
- Rich multi-user dashboard.

## Recommended Local Workflow

1. Start with `WORKFLOW.example.md`.
2. Set `LINEAR_API_KEY` in the shell.
3. Point `tracker.project_slug` at a test Linear project first.
4. Use a temporary `workspace.root`.
5. Run `--once` before daemon mode.
6. Only then point the workflow at active SongDao issues.

## Test

```sh
flutter test test/symphony/symphony_test.dart
flutter analyze
```

