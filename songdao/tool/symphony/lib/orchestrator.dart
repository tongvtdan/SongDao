import 'dart:async';

import 'config.dart';
import 'github_client.dart';
import 'models.dart';

typedef WorkerRunner =
    Future<RunAttemptResult> Function(
      SymphonyIssue issue,
      int? attempt,
      OrchestratorEventSink events,
    );

abstract class WorkspaceCleaner {
  Future<void> cleanWorkspaceForIssue(String issueIdentifier);
}

abstract class Clock {
  DateTime nowUtc();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class OrchestratorEventSink {
  OrchestratorEventSink(this._onEvent);

  final void Function(String issueId, CodexRuntimeEvent event) _onEvent;

  void emit(String issueId, CodexRuntimeEvent event) =>
      _onEvent(issueId, event);
}

class CodexRuntimeEvent {
  const CodexRuntimeEvent({
    required this.event,
    required this.timestamp,
    this.sessionId,
    this.message,
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
    this.rateLimits,
  });

  final String event;
  final DateTime timestamp;
  final String? sessionId;
  final String? message;
  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;
  final Map<String, Object?>? rateLimits;
}

class Orchestrator {
  Orchestrator({
    required this.config,
    required this.tracker,
    required this.workerRunner,
    required this.workspaceCleaner,
    this._clock = const SystemClock(),
  });

  SymphonyConfig config;
  final IssueTrackerClient tracker;
  final WorkerRunner workerRunner;
  final WorkspaceCleaner workspaceCleaner;
  final Clock _clock;

  final running = <String, RunningEntry>{};
  final claimed = <String>{};
  final retryAttempts = <String, RetryEntry>{};
  final completed = <String>{};
  final codexTotals = CodexTotals();
  Map<String, Object?>? codexRateLimits;

  Future<void> tick() async {
    await reconcileRunningIssues();
    final validation = config.validateForDispatch();
    if (validation.isNotEmpty) {
      throw validation.first;
    }
    final candidates = await tracker.fetchCandidateIssues();
    for (final issue in sortForDispatch(candidates)) {
      if (_availableGlobalSlots() <= 0) break;
      if (shouldDispatch(issue)) {
        dispatch(issue, attempt: null);
      }
    }
  }

  List<SymphonyIssue> sortForDispatch(List<SymphonyIssue> issues) {
    final sorted = [...issues];
    sorted.sort((a, b) {
      final priorityA = a.priority ?? 1 << 30;
      final priorityB = b.priority ?? 1 << 30;
      final priority = priorityA.compareTo(priorityB);
      if (priority != 0) return priority;
      final createdA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final createdB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final created = createdA.compareTo(createdB);
      if (created != 0) return created;
      return a.identifier.compareTo(b.identifier);
    });
    return sorted;
  }

  bool shouldDispatch(SymphonyIssue issue) {
    if (!issue.hasDispatchIdentity) return false;
    if (!config.isActiveState(issue.state)) return false;
    if (config.isTerminalState(issue.state)) return false;
    if (running.containsKey(issue.id) || claimed.contains(issue.id)) {
      return false;
    }
    if (_availableGlobalSlots() <= 0) return false;
    if (_availableStateSlots(issue.state) <= 0) return false;
    if (_isInitialActiveState(issue.state) && _hasNonTerminalBlocker(issue)) {
      return false;
    }
    return true;
  }

  void dispatch(SymphonyIssue issue, {required int? attempt}) {
    claimed.add(issue.id);
    retryAttempts.remove(issue.id)?.cancel();
    final entry = RunningEntry(
      issue: issue,
      retryAttempt: attempt,
      startedAt: _clock.nowUtc(),
    );
    running[issue.id] = entry;

    unawaited(() async {
      final result = await workerRunner(
        issue,
        attempt,
        OrchestratorEventSink(_recordCodexEvent),
      );
      await onWorkerExit(issue.id, result);
    }());
  }

  Future<void> onWorkerExit(String issueId, RunAttemptResult result) async {
    final entry = running.remove(issueId);
    if (entry == null) return;
    codexTotals.inputTokens += result.inputTokens;
    codexTotals.outputTokens += result.outputTokens;
    codexTotals.totalTokens += result.totalTokens;
    codexTotals.secondsRunning +=
        _clock.nowUtc().difference(entry.startedAt).inMilliseconds / 1000;
    if (result.isNormal) {
      completed.add(issueId);
      scheduleRetry(
        issueId,
        identifier: entry.issue.identifier,
        attempt: 1,
        delayMs: 1000,
        error: null,
      );
    } else {
      scheduleRetry(
        issueId,
        identifier: entry.issue.identifier,
        attempt: (entry.retryAttempt ?? 0) + 1,
        error: result.error ?? result.reason.name,
      );
    }
  }

  void scheduleRetry(
    String issueId, {
    required String identifier,
    required int attempt,
    int? delayMs,
    String? error,
  }) {
    retryAttempts.remove(issueId)?.cancel();
    final effectiveDelayMs =
        delayMs ??
        _minInt(
          10000 * (1 << (attempt - 1).clamp(0, 20)),
          config.agent.maxRetryBackoffMs,
        );
    late final Timer timer;
    timer = Timer(Duration(milliseconds: effectiveDelayMs), () {
      unawaited(onRetryTimer(issueId));
    });
    retryAttempts[issueId] = RetryEntry(
      issueId: issueId,
      identifier: identifier,
      attempt: attempt,
      dueAt: _clock.nowUtc().add(Duration(milliseconds: effectiveDelayMs)),
      timer: timer,
      error: error,
    );
  }

  Future<void> onRetryTimer(String issueId) async {
    final retry = retryAttempts.remove(issueId);
    if (retry == null) return;
    final candidates = await tracker.fetchCandidateIssues();
    final issue = candidates
        .where((candidate) => candidate.id == issueId)
        .firstOrNull;
    if (issue == null) {
      claimed.remove(issueId);
      return;
    }
    if (_availableGlobalSlots() <= 0 || !shouldDispatchForRetry(issue)) {
      scheduleRetry(
        issueId,
        identifier: issue.identifier,
        attempt: retry.attempt + 1,
        error: 'no available orchestrator slots',
      );
      return;
    }
    dispatch(issue, attempt: retry.attempt);
  }

  bool shouldDispatchForRetry(SymphonyIssue issue) {
    if (!issue.hasDispatchIdentity) return false;
    if (!config.isActiveState(issue.state)) return false;
    if (running.containsKey(issue.id)) return false;
    if (_availableGlobalSlots() <= 0) return false;
    if (_availableStateSlots(issue.state) <= 0) return false;
    if (_isInitialActiveState(issue.state) && _hasNonTerminalBlocker(issue)) {
      return false;
    }
    return true;
  }

  Future<void> reconcileRunningIssues() async {
    _reconcileStalledRuns();
    if (running.isEmpty) return;
    final refreshed = await tracker.fetchIssueStatesByIds(
      running.keys.toList(),
    );
    final byId = {for (final issue in refreshed) issue.id: issue};
    for (final entry in [...running.entries]) {
      final issue = byId[entry.key];
      if (issue == null) continue;
      if (config.isTerminalState(issue.state)) {
        running.remove(entry.key);
        claimed.remove(entry.key);
        await workspaceCleaner.cleanWorkspaceForIssue(
          entry.value.issue.identifier,
        );
      } else if (config.isActiveState(issue.state)) {
        running[entry.key] = entry.value.copyWith(issue: issue);
      } else {
        running.remove(entry.key);
        claimed.remove(entry.key);
      }
    }
  }

  RuntimeSnapshot snapshot() {
    final now = _clock.nowUtc();
    return RuntimeSnapshot(
      generatedAt: now,
      running: running.values.map((entry) => entry.toSnapshotRow()).toList(),
      retrying: retryAttempts.values
          .map((entry) => entry.toSnapshotRow())
          .toList(),
      totals: codexTotals.copyWith(
        secondsRunning:
            codexTotals.secondsRunning +
            running.values.fold<double>(
              0,
              (sum, entry) =>
                  sum + now.difference(entry.startedAt).inMilliseconds / 1000,
            ),
      ),
      rateLimits: codexRateLimits,
    );
  }

  void _reconcileStalledRuns() {
    final stallMs = config.codex.stallTimeoutMs;
    if (stallMs <= 0) return;
    final now = _clock.nowUtc();
    for (final entry in [...running.entries]) {
      final last = entry.value.lastCodexTimestamp ?? entry.value.startedAt;
      if (now.difference(last).inMilliseconds > stallMs) {
        running.remove(entry.key);
        scheduleRetry(
          entry.key,
          identifier: entry.value.issue.identifier,
          attempt: (entry.value.retryAttempt ?? 0) + 1,
          error: 'stalled session',
        );
      }
    }
  }

  void _recordCodexEvent(String issueId, CodexRuntimeEvent event) {
    final entry = running[issueId];
    if (entry == null) return;
    running[issueId] = entry.apply(event);
    if (event.rateLimits != null) {
      codexRateLimits = event.rateLimits;
    }
  }

  bool _hasNonTerminalBlocker(SymphonyIssue issue) {
    return issue.blockedBy.any((blocker) {
      final state = blocker.state;
      if (state == null) return true;
      return !config.isTerminalState(state);
    });
  }

  bool _isInitialActiveState(String state) {
    final activeStates = config.tracker.activeStates;
    return activeStates.isNotEmpty &&
        state.toLowerCase() == activeStates.first.toLowerCase();
  }

  int _availableGlobalSlots() => _minInt(
    config.agent.maxConcurrentAgents - running.length,
    config.agent.maxConcurrentAgents,
  );

  int _availableStateSlots(String state) {
    final key = state.toLowerCase();
    final maxForState =
        config.agent.maxConcurrentAgentsByState[key] ??
        config.agent.maxConcurrentAgents;
    final runningForState = running.values
        .where((entry) => entry.issue.state.toLowerCase() == key)
        .length;
    return maxForState - runningForState;
  }
}

class RunningEntry {
  const RunningEntry({
    required this.issue,
    required this.retryAttempt,
    required this.startedAt,
    this.sessionId,
    this.lastCodexEvent,
    this.lastCodexTimestamp,
    this.lastCodexMessage,
    this.codexInputTokens = 0,
    this.codexOutputTokens = 0,
    this.codexTotalTokens = 0,
    this.turnCount = 0,
  });

  final SymphonyIssue issue;
  final int? retryAttempt;
  final DateTime startedAt;
  final String? sessionId;
  final String? lastCodexEvent;
  final DateTime? lastCodexTimestamp;
  final String? lastCodexMessage;
  final int codexInputTokens;
  final int codexOutputTokens;
  final int codexTotalTokens;
  final int turnCount;

  RunningEntry copyWith({SymphonyIssue? issue}) {
    return RunningEntry(
      issue: issue ?? this.issue,
      retryAttempt: retryAttempt,
      startedAt: startedAt,
      sessionId: sessionId,
      lastCodexEvent: lastCodexEvent,
      lastCodexTimestamp: lastCodexTimestamp,
      lastCodexMessage: lastCodexMessage,
      codexInputTokens: codexInputTokens,
      codexOutputTokens: codexOutputTokens,
      codexTotalTokens: codexTotalTokens,
      turnCount: turnCount,
    );
  }

  RunningEntry apply(CodexRuntimeEvent event) {
    return RunningEntry(
      issue: issue,
      retryAttempt: retryAttempt,
      startedAt: startedAt,
      sessionId: event.sessionId ?? sessionId,
      lastCodexEvent: event.event,
      lastCodexTimestamp: event.timestamp,
      lastCodexMessage: event.message ?? lastCodexMessage,
      codexInputTokens: event.inputTokens ?? codexInputTokens,
      codexOutputTokens: event.outputTokens ?? codexOutputTokens,
      codexTotalTokens: event.totalTokens ?? codexTotalTokens,
      turnCount: event.event == 'turn_started' ? turnCount + 1 : turnCount,
    );
  }

  RunningSnapshotRow toSnapshotRow() {
    return RunningSnapshotRow(
      issueId: issue.id,
      issueIdentifier: issue.identifier,
      state: issue.state,
      sessionId: sessionId,
      turnCount: turnCount,
      lastEvent: lastCodexEvent,
      lastMessage: lastCodexMessage,
      startedAt: startedAt,
      lastEventAt: lastCodexTimestamp,
      inputTokens: codexInputTokens,
      outputTokens: codexOutputTokens,
      totalTokens: codexTotalTokens,
    );
  }
}

class RetryEntry {
  RetryEntry({
    required this.issueId,
    required this.identifier,
    required this.attempt,
    required this.dueAt,
    required this.timer,
    required this.error,
  });

  final String issueId;
  final String identifier;
  final int attempt;
  final DateTime dueAt;
  final Timer timer;
  final String? error;

  void cancel() => timer.cancel();

  RetryingSnapshotRow toSnapshotRow() {
    return RetryingSnapshotRow(
      issueId: issueId,
      issueIdentifier: identifier,
      attempt: attempt,
      dueAt: dueAt,
      error: error,
    );
  }
}

class CodexTotals {
  CodexTotals({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.totalTokens = 0,
    this.secondsRunning = 0,
  });

  int inputTokens;
  int outputTokens;
  int totalTokens;
  double secondsRunning;

  CodexTotals copyWith({double? secondsRunning}) {
    return CodexTotals(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: totalTokens,
      secondsRunning: secondsRunning ?? this.secondsRunning,
    );
  }
}

class RuntimeSnapshot {
  const RuntimeSnapshot({
    required this.generatedAt,
    required this.running,
    required this.retrying,
    required this.totals,
    required this.rateLimits,
  });

  final DateTime generatedAt;
  final List<RunningSnapshotRow> running;
  final List<RetryingSnapshotRow> retrying;
  final CodexTotals totals;
  final Map<String, Object?>? rateLimits;
}

class RunningSnapshotRow {
  const RunningSnapshotRow({
    required this.issueId,
    required this.issueIdentifier,
    required this.state,
    required this.sessionId,
    required this.turnCount,
    required this.lastEvent,
    required this.lastMessage,
    required this.startedAt,
    required this.lastEventAt,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
  });

  final String issueId;
  final String issueIdentifier;
  final String state;
  final String? sessionId;
  final int turnCount;
  final String? lastEvent;
  final String? lastMessage;
  final DateTime startedAt;
  final DateTime? lastEventAt;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
}

class RetryingSnapshotRow {
  const RetryingSnapshotRow({
    required this.issueId,
    required this.issueIdentifier,
    required this.attempt,
    required this.dueAt,
    required this.error,
  });

  final String issueId;
  final String issueIdentifier;
  final int attempt;
  final DateTime dueAt;
  final String? error;
}

int _minInt(int a, int b) => a < b ? a : b;

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
