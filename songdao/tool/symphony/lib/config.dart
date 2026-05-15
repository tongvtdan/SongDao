import 'dart:io';

import 'models.dart';

class SymphonyConfig {
  SymphonyConfig({
    required this.workflowPath,
    required this.tracker,
    required this.polling,
    required this.workspace,
    required this.hooks,
    required this.agent,
    required this.codex,
    required this.server,
  });

  final String workflowPath;
  final TrackerConfig tracker;
  final PollingConfig polling;
  final WorkspaceConfig workspace;
  final HooksConfig hooks;
  final AgentConfig agent;
  final CodexConfig codex;
  final ServerConfig server;

  static SymphonyConfig fromWorkflow({
    required WorkflowDefinition workflow,
    required String workflowPath,
    Map<String, String>? environment,
  }) {
    final env = environment ?? Platform.environment;
    final raw = workflow.config;
    final workflowDir = File(workflowPath).absolute.parent.path;

    final tracker = _map(raw['tracker']);
    final polling = _map(raw['polling']);
    final workspace = _map(raw['workspace']);
    final hooks = _map(raw['hooks']);
    final agent = _map(raw['agent']);
    final codex = _map(raw['codex']);
    final server = _map(raw['server']);

    return SymphonyConfig(
      workflowPath: workflowPath,
      tracker: TrackerConfig(
        kind: _string(tracker['kind']),
        endpoint:
            _string(tracker['endpoint']) ?? 'https://api.linear.app/graphql',
        apiKey:
            _resolveEnv(_string(tracker['api_key']), env) ??
            env['LINEAR_API_KEY'],
        projectSlug: _string(tracker['project_slug']),
        activeStates:
            _stringList(tracker['active_states']) ??
            const ['Todo', 'In Progress'],
        terminalStates:
            _stringList(tracker['terminal_states']) ??
            const ['Closed', 'Cancelled', 'Canceled', 'Duplicate', 'Done'],
      ),
      polling: PollingConfig(
        intervalMs: _positiveInt(polling['interval_ms'], 30000),
      ),
      workspace: WorkspaceConfig(
        root: _resolvePath(
          _resolveEnv(_string(workspace['root']), env) ??
              '${Directory.systemTemp.path}/symphony_workspaces',
          workflowDir,
          env,
        ),
      ),
      hooks: HooksConfig(
        afterCreate: _string(hooks['after_create']),
        beforeRun: _string(hooks['before_run']),
        afterRun: _string(hooks['after_run']),
        beforeRemove: _string(hooks['before_remove']),
        timeoutMs: _positiveInt(hooks['timeout_ms'], 60000),
      ),
      agent: AgentConfig(
        maxConcurrentAgents: _positiveInt(agent['max_concurrent_agents'], 10),
        maxTurns: _positiveInt(agent['max_turns'], 20),
        maxRetryBackoffMs: _positiveInt(agent['max_retry_backoff_ms'], 300000),
        maxConcurrentAgentsByState: _stateConcurrency(
          _map(agent['max_concurrent_agents_by_state']),
        ),
      ),
      codex: CodexConfig(
        command: _string(codex['command']) ?? 'codex app-server',
        approvalPolicy: _string(codex['approval_policy']),
        threadSandbox: _string(codex['thread_sandbox']),
        turnSandboxPolicy: _string(codex['turn_sandbox_policy']),
        turnTimeoutMs: _positiveInt(codex['turn_timeout_ms'], 3600000),
        readTimeoutMs: _positiveInt(codex['read_timeout_ms'], 5000),
        stallTimeoutMs: _int(codex['stall_timeout_ms']) ?? 300000,
      ),
      server: ServerConfig(port: _int(server['port'])),
    );
  }

  List<SymphonyFailure> validateForDispatch() {
    final failures = <SymphonyFailure>[];
    if (tracker.kind == null || tracker.kind!.isEmpty) {
      failures.add(
        const SymphonyFailure(
          'missing_tracker_kind',
          'tracker.kind is required.',
        ),
      );
    } else if (tracker.kind != 'linear') {
      failures.add(
        SymphonyFailure(
          'unsupported_tracker_kind',
          'Unsupported tracker kind: ${tracker.kind}.',
        ),
      );
    }
    if (tracker.apiKey == null || tracker.apiKey!.isEmpty) {
      failures.add(
        const SymphonyFailure(
          'missing_tracker_api_key',
          'Linear API key is required.',
        ),
      );
    }
    if (tracker.projectSlug == null || tracker.projectSlug!.isEmpty) {
      failures.add(
        const SymphonyFailure(
          'missing_tracker_project_slug',
          'tracker.project_slug is required.',
        ),
      );
    }
    if (codex.command.trim().isEmpty) {
      failures.add(
        const SymphonyFailure(
          'missing_codex_command',
          'codex.command is required.',
        ),
      );
    }
    return failures;
  }

  bool isActiveState(String state) =>
      tracker.normalizedActiveStates.contains(state.toLowerCase());

  bool isTerminalState(String state) =>
      tracker.normalizedTerminalStates.contains(state.toLowerCase());
}

class TrackerConfig {
  const TrackerConfig({
    required this.kind,
    required this.endpoint,
    required this.apiKey,
    required this.projectSlug,
    required this.activeStates,
    required this.terminalStates,
  });

  final String? kind;
  final String endpoint;
  final String? apiKey;
  final String? projectSlug;
  final List<String> activeStates;
  final List<String> terminalStates;

  Set<String> get normalizedActiveStates =>
      activeStates.map((state) => state.toLowerCase()).toSet();

  Set<String> get normalizedTerminalStates =>
      terminalStates.map((state) => state.toLowerCase()).toSet();
}

class PollingConfig {
  const PollingConfig({required this.intervalMs});
  final int intervalMs;
}

class WorkspaceConfig {
  const WorkspaceConfig({required this.root});
  final String root;
}

class HooksConfig {
  const HooksConfig({
    required this.afterCreate,
    required this.beforeRun,
    required this.afterRun,
    required this.beforeRemove,
    required this.timeoutMs,
  });

  final String? afterCreate;
  final String? beforeRun;
  final String? afterRun;
  final String? beforeRemove;
  final int timeoutMs;
}

class AgentConfig {
  const AgentConfig({
    required this.maxConcurrentAgents,
    required this.maxTurns,
    required this.maxRetryBackoffMs,
    required this.maxConcurrentAgentsByState,
  });

  final int maxConcurrentAgents;
  final int maxTurns;
  final int maxRetryBackoffMs;
  final Map<String, int> maxConcurrentAgentsByState;
}

class CodexConfig {
  const CodexConfig({
    required this.command,
    required this.approvalPolicy,
    required this.threadSandbox,
    required this.turnSandboxPolicy,
    required this.turnTimeoutMs,
    required this.readTimeoutMs,
    required this.stallTimeoutMs,
  });

  final String command;
  final String? approvalPolicy;
  final String? threadSandbox;
  final String? turnSandboxPolicy;
  final int turnTimeoutMs;
  final int readTimeoutMs;
  final int stallTimeoutMs;
}

class ServerConfig {
  const ServerConfig({required this.port});
  final int? port;
}

Map<String, Object?> _map(Object? value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, Object?>{};
}

String? _string(Object? value) => value?.toString();

int? _int(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

int _positiveInt(Object? value, int fallback) {
  final parsed = _int(value);
  if (parsed == null) return fallback;
  if (parsed <= 0) {
    throw SymphonyFailure(
      'invalid_config_value',
      'Expected positive integer but got $parsed.',
    );
  }
  return parsed;
}

List<String>? _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  if (value is String) return [value];
  return null;
}

String? _resolveEnv(String? value, Map<String, String> env) {
  if (value == null) return null;
  if (value.startsWith(r'$') && value.length > 1) {
    final resolved = env[value.substring(1)];
    if (resolved == null || resolved.isEmpty) return null;
    return resolved;
  }
  return value;
}

String _resolvePath(String value, String workflowDir, Map<String, String> env) {
  var path = value;
  if (path == '~') {
    path = env['HOME'] ?? path;
  } else if (path.startsWith('~/')) {
    path = '${env['HOME'] ?? '~'}${path.substring(1)}';
  } else if (path.startsWith(r'$')) {
    final slash = path.indexOf('/');
    final name = slash == -1 ? path.substring(1) : path.substring(1, slash);
    final resolved = env[name] ?? '';
    path = slash == -1 ? resolved : '$resolved${path.substring(slash)}';
  }

  final uri = Uri.file(path);
  if (uri.isAbsolute) return File(path).absolute.path;
  return Directory(workflowDir).uri.resolve(path).toFilePath();
}

Map<String, int> _stateConcurrency(Map<String, Object?> raw) {
  final result = <String, int>{};
  for (final entry in raw.entries) {
    final value = _int(entry.value);
    if (value != null && value > 0) {
      result[entry.key.toLowerCase()] = value;
    }
  }
  return result;
}
