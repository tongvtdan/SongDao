// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/symphony/lib/codex_runner.dart';
import '../../tool/symphony/lib/config.dart';
import '../../tool/symphony/lib/github_client.dart';
import '../../tool/symphony/lib/models.dart';
import '../../tool/symphony/lib/orchestrator.dart';
import '../../tool/symphony/lib/template.dart';
import '../../tool/symphony/lib/workflow.dart';
import '../../tool/symphony/lib/workspace_manager.dart';

void main() {
  group('workflow and config', () {
    test('loads front matter, prompt body, defaults, and env indirection', () {
      final workflow = const WorkflowLoader().parse('''
---
tracker:
  kind: github
  token: \$GITHUB_TOKEN
  owner: tongvtdan
  project_number: 8
  repository: tongvtdan/SongDao
workspace:
  root: workspaces
agent:
  max_concurrent_agents_by_state:
    Ready: 1
hooks:
  before_run: |
    echo before
---
Work on {{ issue.identifier }}.
''');

      final config = SymphonyConfig.fromWorkflow(
        workflow: workflow,
        workflowPath: '/tmp/repo/WORKFLOW.md',
        environment: {'GITHUB_TOKEN': 'secret'},
      );

      expect(workflow.promptTemplate, 'Work on {{ issue.identifier }}.');
      expect(config.tracker.token, 'secret');
      expect(config.tracker.owner, 'tongvtdan');
      expect(config.tracker.projectNumber, 8);
      expect(config.tracker.repository, 'tongvtdan/SongDao');
      expect(config.polling.intervalMs, 30000);
      expect(config.workspace.root, '/tmp/repo/workspaces');
      expect(config.agent.maxConcurrentAgentsByState, {'ready': 1});
      expect(config.hooks.beforeRun, 'echo before');
      expect(config.validateForDispatch(), isEmpty);
    });

    test('strict template rejects unknown variables and filters', () {
      const issue = SymphonyIssue(
        id: '1',
        identifier: 'DAN-1',
        title: 'Test',
        state: 'Ready',
      );

      expect(
        const StrictTemplate(
          'Hello {{ issue.identifier }}',
        ).render(issue: issue),
        'Hello DAN-1',
      );
      expect(
        () => const StrictTemplate('{{ issue.missing }}').render(issue: issue),
        throwsA(isA<SymphonyFailure>()),
      );
      expect(
        () => const StrictTemplate(
          '{{ issue.identifier | upcase }}',
        ).render(issue: issue),
        throwsA(isA<SymphonyFailure>()),
      );
    });
  });

  group('GitHub adapter', () {
    test('normalizes paginated candidate issues', () async {
      final workflow = WorkflowDefinition(
        config: {
          'tracker': {
            'kind': 'github',
            'token': 'secret',
            'owner': 'tongvtdan',
            'project_number': 8,
            'repository': 'tongvtdan/SongDao',
          },
        },
        promptTemplate: '',
      );
      final config = SymphonyConfig.fromWorkflow(
        workflow: workflow,
        workflowPath: '/tmp/WORKFLOW.md',
      );
      var calls = 0;
      final client = GitHubIssueTrackerClient(
        config: config,
        poster: (_, _, _, variables) async {
          calls += 1;
          expect(variables['owner'], 'tongvtdan');
          expect(variables['projectNumber'], 8);
          return {
            'data': {
              'user': {
                'projectV2': {
                  'items': {
                    'nodes': [
                      _githubProjectItem(
                        id: 'item-$calls',
                        number: calls,
                        label: 'Backend',
                        blockerState: calls == 1 ? 'CLOSED' : null,
                      ),
                    ],
                    'pageInfo': {
                      'hasNextPage': calls == 1,
                      'endCursor': calls == 1 ? 'cursor-1' : null,
                    },
                  },
                },
              },
            },
          };
        },
      );

      final issues = await client.fetchCandidateIssues();

      expect(issues, hasLength(2));
      expect(issues.first.identifier, 'SongDao#1');
      expect(issues.first.priority, 0);
      expect(issues.first.state, 'Ready');
      expect(issues.first.labels, ['backend']);
      expect(issues.first.blockedBy.single.state, 'Done');
      expect(calls, 2);
    });
  });

  group('orchestrator', () {
    test(
      'sorts and dispatches eligible issues while respecting blockers',
      () async {
        final config = _testConfig(maxConcurrentAgents: 2);
        final tracker = _FakeTracker([
          _issue(
            id: '2',
            identifier: 'DAN-2',
            priority: 2,
            createdAt: DateTime.utc(2026, 1, 2),
          ),
          _issue(
            id: '1',
            identifier: 'DAN-1',
            priority: 1,
            createdAt: DateTime.utc(2026, 1),
          ),
          _issue(
            id: '3',
            identifier: 'DAN-3',
            priority: 1,
            blockedBy: const [IssueBlocker(state: 'In progress')],
          ),
        ]);
        final dispatched = <String>[];
        final orchestrator = Orchestrator(
          config: config,
          tracker: tracker,
          workspaceCleaner: _FakeCleaner(),
          workerRunner: (issue, _, _) async {
            dispatched.add(issue.identifier);
            return const RunAttemptResult(reason: WorkerExitReason.failed);
          },
        );

        await orchestrator.tick();
        await Future<void>.delayed(Duration.zero);

        expect(dispatched, ['DAN-1', 'DAN-2']);
        expect(orchestrator.running, isEmpty);
        expect(orchestrator.retryAttempts, hasLength(2));
        for (final retry in orchestrator.retryAttempts.values) {
          retry.cancel();
        }
      },
    );
  });

  group('workspace manager', () {
    test('sanitizes issue identifiers and enforces root containment', () async {
      final root = await Directory.systemTemp.createTemp('symphony_test_');
      addTearDown(() => root.delete(recursive: true));
      final manager = WorkspaceManager(_testConfig(workspaceRoot: root.path));

      final workspace = await manager.createForIssue('DAN/1 bad');

      expect(workspace.workspaceKey, 'DAN_1_bad');
      expect(await Directory(workspace.path).exists(), isTrue);
      expect(
        () => manager.validateLaunchCwd(workspace.path, root.path),
        throwsA(isA<SymphonyFailure>()),
      );
      manager.validateLaunchCwd(workspace.path, workspace.path);
    });
  });

  group('Codex runner', () {
    test('speaks app-server JSON-RPC lifecycle over stdio', () async {
      final root = await Directory.systemTemp.createTemp('symphony_runner_');
      addTearDown(() => root.delete(recursive: true));
      final fakeServer = File('${root.path}/fake_app_server.dart');
      await fakeServer.writeAsString(r'''
import 'dart:convert';
import 'dart:io';

void main() {
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
    final msg = jsonDecode(line) as Map<String, dynamic>;
    final method = msg['method'];
    final id = msg['id'];
    if (method == 'initialize') {
      stdout.writeln(jsonEncode({'id': id, 'result': {}}));
    } else if (method == 'initialized') {
    } else if (method == 'thread/start') {
      stdout.writeln(jsonEncode({'id': id, 'result': {'thread': {'id': 'thr_1'}}}));
    } else if (method == 'turn/start') {
      stdout.writeln(jsonEncode({'id': id, 'result': {'turn': {'id': 'turn_1'}}}));
      stdout.writeln(jsonEncode({
        'method': 'thread/tokenUsage/updated',
        'params': {'usage': {'input_tokens': 3, 'output_tokens': 5, 'total_tokens': 8}}
      }));
      stdout.writeln(jsonEncode({'method': 'turn/completed', 'params': {'status': 'completed'}}));
    }
  });
}
''');

      final config = _testConfig(
        workspaceRoot: '${root.path}/workspaces',
        codexCommand: 'dart ${fakeServer.path}',
      );
      final manager = WorkspaceManager(config);
      final runner = CodexRunner(
        config: config,
        workflow: const WorkflowDefinition(
          config: {},
          promptTemplate: 'Do {{ issue.identifier }}',
        ),
        workspaceManager: manager,
      );
      final events = <CodexRuntimeEvent>[];

      final result = await runner.run(
        _issue(id: '1', identifier: 'DAN-1'),
        null,
        OrchestratorEventSink((_, event) => events.add(event)),
      );

      expect(result.reason, WorkerExitReason.normal);
      expect(result.totalTokens, 8);
      expect(events.map((event) => event.event), contains('session_started'));
      expect(events.map((event) => event.event), contains('turn_completed'));
      expect(events.last.sessionId, 'thr_1-turn_1');
    });
  });
}

Map<String, Object?> _githubProjectItem({
  required String id,
  required int number,
  required String label,
  String? blockerState,
}) {
  return {
    'id': id,
    'updatedAt': '2026-01-02T00:00:00Z',
    'status': {'name': 'Ready'},
    'priorityValue': {'name': 'P0'},
    'content': {
      'id': 'issue-$number',
      'number': number,
      'title': 'Title',
      'body': null,
      'url': 'https://github.com/tongvtdan/SongDao/issues/$number',
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-02T00:00:00Z',
      'repository': {'nameWithOwner': 'tongvtdan/SongDao'},
      'labels': {
        'nodes': [
          {'name': label},
        ],
      },
      'blockedBy': {
        'nodes': blockerState == null
            ? const <Map<String, Object?>>[]
            : [
                {
                  'id': 'blocker',
                  'number': 0,
                  'state': blockerState,
                  'repository': {'nameWithOwner': 'tongvtdan/SongDao'},
                },
              ],
      },
    },
  };
}

SymphonyIssue _issue({
  required String id,
  required String identifier,
  int? priority,
  DateTime? createdAt,
  List<IssueBlocker> blockedBy = const [],
}) {
  return SymphonyIssue(
    id: id,
    identifier: identifier,
    title: 'Issue $identifier',
    priority: priority,
    state: 'Ready',
    blockedBy: blockedBy,
    createdAt: createdAt,
  );
}

SymphonyConfig _testConfig({
  int maxConcurrentAgents = 10,
  String? workspaceRoot,
  String? codexCommand,
}) {
  return SymphonyConfig.fromWorkflow(
    workflow: WorkflowDefinition(
      config: {
        'tracker': {
          'kind': 'github',
          'token': 'secret',
          'owner': 'tongvtdan',
          'project_number': 8,
          'repository': 'tongvtdan/SongDao',
        },
        'agent': {'max_concurrent_agents': maxConcurrentAgents},
        if (codexCommand != null) 'codex': {'command': codexCommand},
        if (workspaceRoot != null) 'workspace': {'root': workspaceRoot},
      },
      promptTemplate: '',
    ),
    workflowPath: '/tmp/WORKFLOW.md',
  );
}

class _FakeTracker implements IssueTrackerClient {
  _FakeTracker(this.issues);

  final List<SymphonyIssue> issues;

  @override
  Future<List<SymphonyIssue>> fetchCandidateIssues() async => issues;

  @override
  Future<List<SymphonyIssue>> fetchIssueStatesByIds(
    List<String> issueIds,
  ) async => issues.where((issue) => issueIds.contains(issue.id)).toList();

  @override
  Future<List<SymphonyIssue>> fetchIssuesByStates(
    List<String> stateNames,
  ) async => issues.where((issue) => stateNames.contains(issue.state)).toList();
}

class _FakeCleaner implements WorkspaceCleaner {
  @override
  Future<void> cleanWorkspaceForIssue(String issueIdentifier) async {}
}
