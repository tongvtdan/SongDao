import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'config.dart';
import 'models.dart';
import 'orchestrator.dart';
import 'template.dart';
import 'workspace_manager.dart';

class CodexRunner {
  CodexRunner({
    required this.config,
    required this.workflow,
    required this.workspaceManager,
  });

  final SymphonyConfig config;
  final WorkflowDefinition workflow;
  final WorkspaceManager workspaceManager;

  Future<RunAttemptResult> run(
    SymphonyIssue issue,
    int? attempt,
    OrchestratorEventSink events,
  ) async {
    WorkspaceInfo? workspace;
    Process? process;
    StreamSubscription<String>? stderrSub;
    try {
      workspace = await workspaceManager.createForIssue(issue.identifier);
      await workspaceManager.beforeRun(workspace.path);
      workspaceManager.validateLaunchCwd(workspace.path, workspace.path);

      final prompt = _buildPrompt(issue, attempt, turnNumber: 1);
      process = await Process.start(
        'bash',
        ['-lc', config.codex.command],
        workingDirectory: workspace.path,
        runInShell: false,
      ).timeout(Duration(milliseconds: config.codex.readTimeoutMs));

      var inputTokens = 0;
      var outputTokens = 0;
      var totalTokens = 0;
      var failedReason = '';
      var sessionId = '${process.pid}-pending';
      var nextId = 0;
      final responses = <int, Completer<Map<String, Object?>>>{};
      final turnCompleted = Completer<void>();

      stderrSub = process.stderr.transform(utf8.decoder).listen((message) {
        events.emit(
          issue.id,
          CodexRuntimeEvent(
            event: 'notification',
            timestamp: DateTime.now().toUtc(),
            sessionId: sessionId,
            message: message.trim(),
          ),
        );
      });

      void send(Map<String, Object?> message) {
        process!.stdin.writeln(jsonEncode(message));
      }

      final stdoutDone = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            final decoded = _decodeLine(line);
            if (decoded == null) {
              events.emit(
                issue.id,
                CodexRuntimeEvent(
                  event: 'malformed',
                  timestamp: DateTime.now().toUtc(),
                  sessionId: sessionId,
                  message: line,
                ),
              );
              return;
            }

            final id = decoded['id'];
            if (id is int && responses.containsKey(id)) {
              responses.remove(id)!.complete(decoded);
              return;
            }

            final event = _eventFromNotification(decoded, sessionId);
            if (event == null) return;
            inputTokens = event.inputTokens ?? inputTokens;
            outputTokens = event.outputTokens ?? outputTokens;
            totalTokens = event.totalTokens ?? totalTokens;
            events.emit(issue.id, event);

            if (event.event == 'turn_input_required') {
              failedReason = 'turn input required';
              if (!turnCompleted.isCompleted) turnCompleted.complete();
            } else if (event.event == 'turn_failed' ||
                event.event == 'turn_cancelled') {
              failedReason = event.message ?? event.event;
              if (!turnCompleted.isCompleted) turnCompleted.complete();
            } else if (event.event == 'turn_completed') {
              if (!turnCompleted.isCompleted) turnCompleted.complete();
            }
          })
          .asFuture<void>();

      Future<Map<String, Object?>> request(
        String method,
        Map<String, Object?> params,
      ) async {
        final id = nextId++;
        final completer = Completer<Map<String, Object?>>();
        responses[id] = completer;
        send({'method': method, 'id': id, 'params': params});
        final response = await completer.future.timeout(
          Duration(milliseconds: config.codex.readTimeoutMs),
        );
        if (response['error'] != null) {
          throw SymphonyFailure('response_error', response['error'].toString());
        }
        return response;
      }

      await request('initialize', {
        'clientInfo': {
          'name': 'songdao_symphony',
          'title': 'SongDao Symphony',
          'version': '0.1.0',
        },
      });
      send({'method': 'initialized', 'params': <String, Object?>{}});

      final threadResponse = await request('thread/start', <String, Object?>{});
      final threadId = _threadIdFromResponse(threadResponse);
      final turnResponse = await request('turn/start', {
        'threadId': threadId,
        'cwd': workspace.path,
        'input': [
          {'type': 'text', 'text': prompt},
        ],
      });
      final turnId = _turnIdFromResponse(turnResponse);
      sessionId = '$threadId-$turnId';

      events.emit(
        issue.id,
        CodexRuntimeEvent(
          event: 'session_started',
          timestamp: DateTime.now().toUtc(),
          sessionId: sessionId,
          message: 'pid=${process.pid}',
        ),
      );
      events.emit(
        issue.id,
        CodexRuntimeEvent(
          event: 'turn_started',
          timestamp: DateTime.now().toUtc(),
          sessionId: sessionId,
          message: _summarizePrompt(prompt),
        ),
      );

      await turnCompleted.future.timeout(
        Duration(milliseconds: config.codex.turnTimeoutMs),
        onTimeout: () {
          process?.kill(ProcessSignal.sigterm);
          throw const SymphonyFailure('turn_timeout', 'Codex turn timed out.');
        },
      );

      await process.stdin.close();
      process.kill(ProcessSignal.sigterm);
      await process.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          process?.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
      await stdoutDone.catchError((_) {});
      await stderrSub.cancel();
      await workspaceManager.afterRunBestEffort(workspace.path);

      if (failedReason.isNotEmpty) {
        return RunAttemptResult(
          reason: WorkerExitReason.failed,
          error: failedReason,
          inputTokens: inputTokens,
          outputTokens: outputTokens,
          totalTokens: totalTokens,
        );
      }

      return RunAttemptResult(
        reason: WorkerExitReason.normal,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        totalTokens: totalTokens,
      );
    } on TimeoutException catch (error) {
      process?.kill(ProcessSignal.sigterm);
      if (workspace != null) {
        await workspaceManager.afterRunBestEffort(workspace.path);
      }
      await stderrSub?.cancel();
      return RunAttemptResult(
        reason: WorkerExitReason.timedOut,
        error: error.message ?? 'timeout',
      );
    } on SymphonyFailure catch (error) {
      process?.kill(ProcessSignal.sigterm);
      if (workspace != null) {
        await workspaceManager.afterRunBestEffort(workspace.path);
      }
      await stderrSub?.cancel();
      return RunAttemptResult(
        reason: error.code == 'turn_timeout'
            ? WorkerExitReason.timedOut
            : WorkerExitReason.failed,
        error: error.toString(),
      );
    } catch (error) {
      process?.kill(ProcessSignal.sigterm);
      if (workspace != null) {
        await workspaceManager.afterRunBestEffort(workspace.path);
      }
      await stderrSub?.cancel();
      return RunAttemptResult(
        reason: WorkerExitReason.failed,
        error: error.toString(),
      );
    }
  }

  String _buildPrompt(
    SymphonyIssue issue,
    int? attempt, {
    required int turnNumber,
  }) {
    if (turnNumber == 1) {
      final source = workflow.promptTemplate.trim().isEmpty
          ? 'You are working on an issue from Linear.'
          : workflow.promptTemplate;
      return StrictTemplate(source).render(issue: issue, attempt: attempt);
    }
    return 'Continue working on ${issue.identifier}. Check the issue state before stopping.';
  }

  String _summarizePrompt(String prompt) {
    final singleLine = prompt.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (singleLine.length <= 120) return singleLine;
    return '${singleLine.substring(0, 120)}...';
  }

  Map<String, Object?>? _decodeLine(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  CodexRuntimeEvent? _eventFromNotification(
    Map<String, Object?> decoded,
    String sessionId,
  ) {
    final method = decoded['method']?.toString();
    if (method == null) return null;
    final params = decoded['params'];
    final usage = _findUsage(params);
    final normalized = switch (method) {
      'turn/completed' => 'turn_completed',
      'turn/failed' => 'turn_failed',
      'turn/cancelled' || 'turn/canceled' => 'turn_cancelled',
      'tool/requestUserInput' => 'turn_input_required',
      'thread/tokenUsage/updated' => 'token_usage_updated',
      _ => method.replaceAll('/', '_'),
    };
    return CodexRuntimeEvent(
      event: normalized,
      timestamp: DateTime.now().toUtc(),
      sessionId: sessionId,
      message: _messageFromParams(params),
      inputTokens: _usageInt(usage, ['input_tokens', 'inputTokens']),
      outputTokens: _usageInt(usage, ['output_tokens', 'outputTokens']),
      totalTokens: _usageInt(usage, ['total_tokens', 'totalTokens']),
      rateLimits:
          _mapField(params, 'rate_limits') ?? _mapField(params, 'rateLimits'),
    );
  }

  Object? _findUsage(Object? params) {
    if (params is! Map) return null;
    return params['usage'] ??
        params['tokenUsage'] ??
        params['total_token_usage'] ??
        params['totalTokenUsage'];
  }

  Map<String, Object?>? _mapField(Object? params, String key) {
    if (params is! Map || params[key] is! Map) return null;
    return (params[key] as Map).map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  String? _messageFromParams(Object? params) {
    if (params is! Map) return null;
    return params['message']?.toString() ??
        params['status']?.toString() ??
        params['error']?.toString();
  }

  String _threadIdFromResponse(Map<String, Object?> response) {
    final result = response['result'];
    if (result is Map) {
      final thread = result['thread'];
      if (thread is Map && thread['id'] is String) {
        return thread['id'] as String;
      }
    }
    throw const SymphonyFailure(
      'response_error',
      'thread/start did not return thread.id.',
    );
  }

  String _turnIdFromResponse(Map<String, Object?> response) {
    final result = response['result'];
    if (result is Map) {
      final turn = result['turn'];
      if (turn is Map && turn['id'] is String) {
        return turn['id'] as String;
      }
    }
    throw const SymphonyFailure(
      'response_error',
      'turn/start did not return turn.id.',
    );
  }

  int? _usageInt(Object? usage, List<String> keys) {
    if (usage is! Map) return null;
    for (final key in keys) {
      final value = usage[key];
      if (value is int) return value;
    }
    return null;
  }
}
