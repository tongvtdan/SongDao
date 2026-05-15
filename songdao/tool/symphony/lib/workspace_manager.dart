import 'dart:async';
import 'dart:io';

import 'config.dart';
import 'models.dart';
import 'orchestrator.dart';

class WorkspaceManager implements WorkspaceCleaner {
  WorkspaceManager(this.config);

  final SymphonyConfig config;

  Future<WorkspaceInfo> createForIssue(String issueIdentifier) async {
    final key = sanitizeIssueIdentifier(issueIdentifier);
    final root = Directory(config.workspace.root).absolute;
    final workspace = Directory('${root.path}/$key').absolute;
    _validateUnderRoot(root.path, workspace.path);

    if (await workspace.exists()) {
      final type = await FileSystemEntity.type(workspace.path);
      if (type != FileSystemEntityType.directory) {
        throw SymphonyFailure(
          'workspace_path_not_directory',
          'Workspace path exists but is not a directory: ${workspace.path}',
        );
      }
      return WorkspaceInfo(
        path: workspace.path,
        workspaceKey: key,
        createdNow: false,
      );
    }

    await workspace.create(recursive: true);
    final info = WorkspaceInfo(
      path: workspace.path,
      workspaceKey: key,
      createdNow: true,
    );
    if (config.hooks.afterCreate != null) {
      await _runHook('after_create', config.hooks.afterCreate!, workspace.path);
    }
    return info;
  }

  Future<void> beforeRun(String workspacePath) async {
    final hook = config.hooks.beforeRun;
    if (hook == null) return;
    await _runHook('before_run', hook, workspacePath);
  }

  Future<void> afterRunBestEffort(String workspacePath) async {
    final hook = config.hooks.afterRun;
    if (hook == null) return;
    try {
      await _runHook('after_run', hook, workspacePath);
    } catch (_) {
      // Observability records hook failures in the caller; cleanup should continue.
    }
  }

  @override
  Future<void> cleanWorkspaceForIssue(String issueIdentifier) async {
    final key = sanitizeIssueIdentifier(issueIdentifier);
    final root = Directory(config.workspace.root).absolute;
    final workspace = Directory('${root.path}/$key').absolute;
    _validateUnderRoot(root.path, workspace.path);
    if (!await workspace.exists()) return;

    final hook = config.hooks.beforeRemove;
    if (hook != null) {
      try {
        await _runHook('before_remove', hook, workspace.path);
      } catch (_) {
        // Cleanup still proceeds by specification.
      }
    }
    await workspace.delete(recursive: true);
  }

  void validateLaunchCwd(String workspacePath, String cwd) {
    final root = Directory(config.workspace.root).absolute.path;
    final workspace = Directory(workspacePath).absolute.path;
    final actual = Directory(cwd).absolute.path;
    _validateUnderRoot(root, workspace);
    if (actual != workspace) {
      throw SymphonyFailure(
        'invalid_workspace_cwd',
        'Codex cwd must match workspace path.',
      );
    }
  }

  static String sanitizeIssueIdentifier(String identifier) {
    return identifier.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  Future<void> _runHook(String name, String script, String cwd) async {
    final process = await Process.start(
      'bash',
      ['-lc', script],
      workingDirectory: cwd,
      runInShell: false,
    );
    final timeout = Duration(milliseconds: config.hooks.timeoutMs);
    final exitCode = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        process.kill(ProcessSignal.sigterm);
        throw SymphonyFailure('hook_timeout', '$name timed out.');
      },
    );
    if (exitCode != 0) {
      throw SymphonyFailure('hook_failed', '$name exited with $exitCode.');
    }
  }

  void _validateUnderRoot(String rootPath, String workspacePath) {
    final root = Directory(rootPath).absolute.uri.normalizePath().toFilePath();
    final workspace = Directory(
      workspacePath,
    ).absolute.uri.normalizePath().toFilePath();
    if (workspace != root &&
        !workspace.startsWith(_withTrailingSeparator(root))) {
      throw SymphonyFailure(
        'workspace_outside_root',
        'Workspace path must stay inside workspace root.',
      );
    }
  }

  String _withTrailingSeparator(String path) {
    return path.endsWith(Platform.pathSeparator)
        ? path
        : '$path${Platform.pathSeparator}';
  }
}
