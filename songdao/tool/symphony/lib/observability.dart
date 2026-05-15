import 'dart:convert';
import 'dart:io';

import 'orchestrator.dart';

class SymphonyLogger {
  const SymphonyLogger();

  void info(String message, {Map<String, Object?> context = const {}}) {
    _write('info', message, context);
  }

  void warn(String message, {Map<String, Object?> context = const {}}) {
    _write('warn', message, context);
  }

  void error(String message, {Map<String, Object?> context = const {}}) {
    _write('error', message, context);
  }

  void _write(String level, String message, Map<String, Object?> context) {
    final fields = {
      'level': level,
      'message': message,
      ...context,
    }.entries.map((entry) => '${entry.key}=${entry.value}').join(' ');
    stderr.writeln(fields);
  }
}

class SymphonyStatusServer {
  SymphonyStatusServer({required this.orchestrator, required this.onRefresh});

  final Orchestrator orchestrator;
  final Future<void> Function() onRefresh;
  HttpServer? _server;

  Future<Uri> start({required int port}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server = server;
    server.listen(_handle);
    return Uri(
      scheme: 'http',
      host: server.address.host,
      port: server.port,
      path: '/',
    );
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/') {
        _html(request, _renderDashboard(orchestrator.snapshot()));
      } else if (request.method == 'GET' && path == '/api/v1/state') {
        _json(request, _snapshotJson(orchestrator.snapshot()));
      } else if (request.method == 'POST' && path == '/api/v1/refresh') {
        await onRefresh();
        _json(request, {
          'queued': true,
          'coalesced': false,
          'requested_at': DateTime.now().toUtc().toIso8601String(),
          'operations': ['poll', 'reconcile'],
        }, status: HttpStatus.accepted);
      } else if (request.method == 'GET' && path.startsWith('/api/v1/')) {
        final identifier = Uri.decodeComponent(
          path.substring('/api/v1/'.length),
        );
        final snapshot = orchestrator.snapshot();
        final running = snapshot.running
            .where((row) => row.issueIdentifier == identifier)
            .firstOrNull;
        final retry = snapshot.retrying
            .where((row) => row.issueIdentifier == identifier)
            .firstOrNull;
        if (running == null && retry == null) {
          _json(request, {
            'error': {
              'code': 'issue_not_found',
              'message': 'Issue is not tracked in current runtime state.',
            },
          }, status: HttpStatus.notFound);
        } else {
          _json(request, {
            'issue_identifier': identifier,
            'status': running != null ? 'running' : 'retrying',
            'running': running == null ? null : _runningJson(running),
            'retry': retry == null ? null : _retryJson(retry),
          });
        }
      } else if (_isDefinedPath(path)) {
        _json(request, {
          'error': {
            'code': 'method_not_allowed',
            'message': 'Unsupported method.',
          },
        }, status: HttpStatus.methodNotAllowed);
      } else {
        _json(request, {
          'error': {'code': 'not_found', 'message': 'Route not found.'},
        }, status: HttpStatus.notFound);
      }
    } catch (error) {
      _json(request, {
        'error': {'code': 'internal_error', 'message': error.toString()},
      }, status: HttpStatus.internalServerError);
    }
  }

  bool _isDefinedPath(String path) {
    return path == '/' || path == '/api/v1/state' || path == '/api/v1/refresh';
  }

  void _json(HttpRequest request, Object body, {int status = HttpStatus.ok}) {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    request.response.close();
  }

  void _html(HttpRequest request, String body) {
    request.response.headers.contentType = ContentType.html;
    request.response.write(body);
    request.response.close();
  }

  String _renderDashboard(RuntimeSnapshot snapshot) {
    return '''
<!doctype html>
<html>
<head><title>Symphony</title></head>
<body>
<h1>Symphony</h1>
<p>Running: ${snapshot.running.length} Retry: ${snapshot.retrying.length}</p>
<pre>${const JsonEncoder.withIndent('  ').convert(_snapshotJson(snapshot))}</pre>
</body>
</html>
''';
  }
}

Map<String, Object?> _snapshotJson(RuntimeSnapshot snapshot) {
  return {
    'generated_at': snapshot.generatedAt.toIso8601String(),
    'counts': {
      'running': snapshot.running.length,
      'retrying': snapshot.retrying.length,
    },
    'running': snapshot.running.map(_runningJson).toList(),
    'retrying': snapshot.retrying.map(_retryJson).toList(),
    'codex_totals': {
      'input_tokens': snapshot.totals.inputTokens,
      'output_tokens': snapshot.totals.outputTokens,
      'total_tokens': snapshot.totals.totalTokens,
      'seconds_running': snapshot.totals.secondsRunning,
    },
    'rate_limits': snapshot.rateLimits,
  };
}

Map<String, Object?> _runningJson(RunningSnapshotRow row) {
  return {
    'issue_id': row.issueId,
    'issue_identifier': row.issueIdentifier,
    'state': row.state,
    'session_id': row.sessionId,
    'turn_count': row.turnCount,
    'last_event': row.lastEvent,
    'last_message': row.lastMessage,
    'started_at': row.startedAt.toIso8601String(),
    'last_event_at': row.lastEventAt?.toIso8601String(),
    'tokens': {
      'input_tokens': row.inputTokens,
      'output_tokens': row.outputTokens,
      'total_tokens': row.totalTokens,
    },
  };
}

Map<String, Object?> _retryJson(RetryingSnapshotRow row) {
  return {
    'issue_id': row.issueId,
    'issue_identifier': row.issueIdentifier,
    'attempt': row.attempt,
    'due_at': row.dueAt.toIso8601String(),
    'error': row.error,
  };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
