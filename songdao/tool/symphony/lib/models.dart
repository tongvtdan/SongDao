class SymphonyIssue {
  const SymphonyIssue({
    required this.id,
    required this.identifier,
    required this.title,
    required this.state,
    this.description,
    this.priority,
    this.branchName,
    this.url,
    this.labels = const [],
    this.blockedBy = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String identifier;
  final String title;
  final String? description;
  final int? priority;
  final String state;
  final String? branchName;
  final String? url;
  final List<String> labels;
  final List<IssueBlocker> blockedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasDispatchIdentity =>
      id.isNotEmpty &&
      identifier.isNotEmpty &&
      title.isNotEmpty &&
      state.isNotEmpty;

  SymphonyIssue copyWith({
    String? state,
    String? title,
    String? description,
    int? priority,
    List<IssueBlocker>? blockedBy,
  }) {
    return SymphonyIssue(
      id: id,
      identifier: identifier,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      state: state ?? this.state,
      branchName: branchName,
      url: url,
      labels: labels,
      blockedBy: blockedBy ?? this.blockedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class IssueBlocker {
  const IssueBlocker({this.id, this.identifier, this.state});

  final String? id;
  final String? identifier;
  final String? state;
}

class WorkflowDefinition {
  const WorkflowDefinition({
    required this.config,
    required this.promptTemplate,
  });

  final Map<String, Object?> config;
  final String promptTemplate;
}

class SymphonyFailure implements Exception {
  const SymphonyFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class WorkspaceInfo {
  const WorkspaceInfo({
    required this.path,
    required this.workspaceKey,
    required this.createdNow,
  });

  final String path;
  final String workspaceKey;
  final bool createdNow;
}

enum WorkerExitReason {
  normal,
  failed,
  timedOut,
  stalled,
  canceledByReconciliation,
}

class RunAttemptResult {
  const RunAttemptResult({
    required this.reason,
    this.error,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.totalTokens = 0,
  });

  final WorkerExitReason reason;
  final String? error;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  bool get isNormal => reason == WorkerExitReason.normal;
}
