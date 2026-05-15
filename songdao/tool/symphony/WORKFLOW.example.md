---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  project_slug: songdao-90622233d8fe
  active_states: [Todo, In Progress]
  terminal_states: [Closed, Cancelled, Canceled, Duplicate, Done]

polling:
  interval_ms: 30000

workspace:
  root: .symphony/workspaces

hooks:
  timeout_ms: 60000
  after_create: |
    git status --short || true
  before_run: |
    pwd
  after_run: |
    true
  before_remove: |
    true

agent:
  max_concurrent_agents: 1
  max_turns: 20
  max_retry_backoff_ms: 300000
  max_concurrent_agents_by_state:
    Todo: 1
    In Progress: 1

codex:
  command: codex app-server
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000

server:
  port: 0
---
You are working on Linear issue {{ issue.identifier }}.

Title: {{ issue.title }}
State: {{ issue.state }}
Priority: {{ issue.priority }}

Work inside the current repository workspace only. Implement the smallest
shippable change, run relevant checks, and leave a concise handoff in Linear
using the tools available in the Codex session.
