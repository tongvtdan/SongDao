import 'dart:async';
import 'dart:io';

import 'config.dart';
import 'models.dart';
import 'workflow.dart';

class WorkflowRuntime {
  WorkflowRuntime({
    required this.workflowPath,
    this._loader = const WorkflowLoader(),
  });

  final String workflowPath;
  final WorkflowLoader _loader;
  WorkflowDefinition? _workflow;
  SymphonyConfig? _config;
  StreamSubscription<FileSystemEvent>? _watch;

  WorkflowDefinition get workflow => _workflow!;
  SymphonyConfig get config => _config!;

  Future<void> start({
    void Function(SymphonyFailure failure)? onReloadError,
  }) async {
    await reload(requireValid: true);
    _watch = File(workflowPath).watch().listen((_) async {
      try {
        await reload(requireValid: false);
      } on SymphonyFailure catch (failure) {
        onReloadError?.call(failure);
      }
    });
  }

  Future<void> stop() async {
    await _watch?.cancel();
  }

  Future<void> reload({required bool requireValid}) async {
    final nextWorkflow = await _loader.load(workflowPath);
    final nextConfig = SymphonyConfig.fromWorkflow(
      workflow: nextWorkflow,
      workflowPath: workflowPath,
    );
    final failures = nextConfig.validateForDispatch();
    if (failures.isNotEmpty && requireValid) {
      throw failures.first;
    }
    _workflow = nextWorkflow;
    _config = nextConfig;
  }
}
