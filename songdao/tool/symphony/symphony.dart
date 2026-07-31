import 'dart:async';
import 'dart:io';

import 'lib/codex_runner.dart';
import 'lib/github_client.dart';
import 'lib/observability.dart';
import 'lib/orchestrator.dart';
import 'lib/workflow.dart';
import 'lib/workflow_runtime.dart';
import 'lib/workspace_manager.dart';

Future<void> main(List<String> args) async {
  final logger = const SymphonyLogger();
  final port = _portArg(args);
  final once = args.contains('--once');
  final workflowArgs = args.where((arg) => !arg.startsWith('--')).toList();
  final workflowPath = const WorkflowPathResolver().resolve(workflowArgs);
  final runtime = WorkflowRuntime(workflowPath: workflowPath);

  try {
    await runtime.start(
      onReloadError: (failure) => logger.error(
        'workflow_reload_failed',
        context: {'code': failure.code, 'reason': failure.message},
      ),
    );
  } catch (error) {
    logger.error('startup_failed', context: {'reason': error});
    exitCode = 1;
    return;
  }

  var workspaceManager = WorkspaceManager(runtime.config);
  var codexRunner = CodexRunner(
    config: runtime.config,
    workflow: runtime.workflow,
    workspaceManager: workspaceManager,
  );
  var orchestrator = Orchestrator(
    config: runtime.config,
    tracker: GitHubIssueTrackerClient(config: runtime.config),
    workspaceCleaner: workspaceManager,
    workerRunner: codexRunner.run,
  );

  void refreshRuntimeObjects() {
    workspaceManager = WorkspaceManager(runtime.config);
    codexRunner = CodexRunner(
      config: runtime.config,
      workflow: runtime.workflow,
      workspaceManager: workspaceManager,
    );
    orchestrator.config = runtime.config;
  }

  final effectivePort = port ?? runtime.config.server.port;
  SymphonyStatusServer? server;
  if (effectivePort != null) {
    server = SymphonyStatusServer(
      orchestrator: orchestrator,
      onRefresh: () async {
        await runtime.reload(requireValid: false);
        refreshRuntimeObjects();
        await orchestrator.tick();
      },
    );
    final uri = await server.start(port: effectivePort);
    logger.info('status_server_started', context: {'url': uri});
  }

  Future<void> runTick() async {
    await runtime.reload(requireValid: false);
    refreshRuntimeObjects();
    await orchestrator.tick();
  }

  if (once) {
    await runTick();
    await server?.stop();
    await runtime.stop();
    return;
  }

  logger.info('symphony_started', context: {'workflow': workflowPath});
  await runTick();
  final timer = Timer.periodic(
    Duration(milliseconds: runtime.config.polling.intervalMs),
    (_) {
      unawaited(
        runTick().catchError((Object error) {
          logger.error('tick_failed', context: {'reason': error});
        }),
      );
    },
  );

  ProcessSignal.sigint.watch().listen((_) async {
    timer.cancel();
    await server?.stop();
    await runtime.stop();
    exit(0);
  });
}

int? _portArg(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--port=')) {
      return int.tryParse(arg.substring('--port='.length));
    }
  }
  return null;
}
