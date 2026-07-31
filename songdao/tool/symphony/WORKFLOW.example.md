---
tracker:
  kind: github
  token: $GITHUB_TOKEN
  owner: tongvtdan
  project_number: 8
  repository: tongvtdan/SongDao
  status_field: Status
  priority_field: Priority
  active_states: [Ready, In progress]
  terminal_states: [Done]

polling:
  interval_ms: 30000

workspace:
  root: .symphony/workspaces

hooks:
  timeout_ms: 60000
  after_create: |
    git clone --origin origin https://github.com/tongvtdan/SongDao.git .
  before_run: |
    git remote get-url origin
    git status --short
  after_run: |
    true
  before_remove: |
    true

agent:
  max_concurrent_agents: 1
  max_turns: 20
  max_retry_backoff_ms: 300000
  max_concurrent_agents_by_state:
    Ready: 1
    In progress: 1

codex:
  command: codex app-server
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000

server:
  port: 0
---
You are working on GitHub issue {{ issue.identifier }}.

Title: {{ issue.title }}
State: {{ issue.state }}
Priority: {{ issue.priority }}

Work inside the current repository workspace only. Implement the smallest
shippable change, run relevant checks, and leave a concise handoff on the
GitHub issue using the tools available in the Codex session.
