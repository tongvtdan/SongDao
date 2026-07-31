import 'dart:convert';
import 'dart:io';

import 'config.dart';
import 'models.dart';

abstract class IssueTrackerClient {
  Future<List<SymphonyIssue>> fetchCandidateIssues();
  Future<List<SymphonyIssue>> fetchIssuesByStates(List<String> stateNames);
  Future<List<SymphonyIssue>> fetchIssueStatesByIds(List<String> issueIds);
}

typedef GraphQlPoster =
    Future<Map<String, Object?>> Function(
      String endpoint,
      String token,
      String query,
      Map<String, Object?> variables,
    );

class GitHubIssueTrackerClient implements IssueTrackerClient {
  GitHubIssueTrackerClient({required this.config, GraphQlPoster? poster})
    : _poster = poster ?? _defaultPoster;

  final SymphonyConfig config;
  final GraphQlPoster _poster;

  @override
  Future<List<SymphonyIssue>> fetchCandidateIssues() {
    return _fetchProjectIssues(states: config.tracker.activeStates);
  }

  @override
  Future<List<SymphonyIssue>> fetchIssuesByStates(List<String> stateNames) {
    if (stateNames.isEmpty) return Future.value(const []);
    return _fetchProjectIssues(states: stateNames);
  }

  @override
  Future<List<SymphonyIssue>> fetchIssueStatesByIds(
    List<String> issueIds,
  ) async {
    if (issueIds.isEmpty) return const [];
    final response = await _post(_issueStateQuery, {
      'ids': issueIds,
      'statusField': config.tracker.statusField,
      'priorityField': config.tracker.priorityField,
    });
    final nodes = _nodes(response, ['data', 'nodes']);
    return _normalizeIssues(nodes);
  }

  Future<List<SymphonyIssue>> _fetchProjectIssues({
    required List<String> states,
  }) async {
    final all = <SymphonyIssue>[];
    String? cursor;
    while (true) {
      final response = await _post(_candidateQuery, {
        'owner': config.tracker.owner,
        'projectNumber': config.tracker.projectNumber,
        'after': cursor,
        'first': 50,
        'statusField': config.tracker.statusField,
        'priorityField': config.tracker.priorityField,
      });
      final items = _getPath(response, ['data', 'user', 'projectV2', 'items']);
      if (items is! Map) {
        throw const SymphonyFailure(
          'github_unknown_payload',
          'GitHub response did not include the user project items.',
        );
      }
      all.addAll(
        _normalizeIssues(
          _nodes(response, ['data', 'user', 'projectV2', 'items']),
        ).where(
          (issue) => states.any(
            (state) => state.toLowerCase() == issue.state.toLowerCase(),
          ),
        ),
      );
      final pageInfo = items['pageInfo'];
      if (pageInfo is! Map) {
        throw const SymphonyFailure(
          'github_unknown_payload',
          'GitHub response did not include project item pageInfo.',
        );
      }
      final hasNextPage = pageInfo['hasNextPage'] == true;
      if (!hasNextPage) break;
      final endCursor = pageInfo['endCursor'];
      if (endCursor is! String || endCursor.isEmpty) {
        throw const SymphonyFailure(
          'github_missing_end_cursor',
          'GitHub pagination did not return endCursor.',
        );
      }
      cursor = endCursor;
    }
    return all;
  }

  List<SymphonyIssue> _normalizeIssues(List<Map<String, Object?>> nodes) {
    final repository = config.tracker.repository!;
    return nodes
        .map((node) => _normalizeIssue(node, repository))
        .whereType<SymphonyIssue>()
        .toList(growable: false);
  }

  Future<Map<String, Object?>> _post(
    String query,
    Map<String, Object?> variables,
  ) async {
    final token = config.tracker.token;
    if (token == null || token.isEmpty) {
      throw const SymphonyFailure(
        'missing_tracker_token',
        'GitHub token is required.',
      );
    }
    try {
      final response = await _poster(
        config.tracker.endpoint,
        token,
        query,
        variables,
      );
      final errors = response['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw SymphonyFailure(
          'github_graphql_errors',
          'GitHub GraphQL returned ${errors.length} error(s).',
        );
      }
      return response;
    } on SymphonyFailure {
      rethrow;
    } catch (error) {
      throw SymphonyFailure('github_api_request', error.toString());
    }
  }

  static Future<Map<String, Object?>> _defaultPoster(
    String endpoint,
    String token,
    String query,
    Map<String, Object?> variables,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'SongDao-Symphony');
      request.write(jsonEncode({'query': query, 'variables': variables}));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw SymphonyFailure(
          'github_api_status',
          'GitHub returned HTTP ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      throw const SymphonyFailure(
        'github_unknown_payload',
        'GitHub response body was not a JSON object.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

List<Map<String, Object?>> _nodes(
  Map<String, Object?> response,
  List<String> path,
) {
  final value = _getPath(response, path);
  final nodes = value is Map ? value['nodes'] : value;
  if (nodes is! List) {
    throw const SymphonyFailure(
      'github_unknown_payload',
      'Expected GitHub nodes.',
    );
  }
  return nodes
      .whereType<Map>()
      .map((node) => node.map((key, value) => MapEntry(key.toString(), value)))
      .toList(growable: false);
}

Object? _getPath(Map<String, Object?> root, List<String> path) {
  Object? current = root;
  for (final segment in path) {
    if (current is Map) {
      current = current[segment];
    } else {
      return null;
    }
  }
  return current;
}

SymphonyIssue? _normalizeIssue(
  Map<String, Object?> node,
  String expectedRepository,
) {
  final content = node['content'];
  if (content is! Map) return null;
  final repository = content['repository'];
  final nameWithOwner = repository is Map
      ? _nullableString(repository['nameWithOwner'])
      : null;
  if (nameWithOwner == null ||
      nameWithOwner.toLowerCase() != expectedRepository.toLowerCase()) {
    return null;
  }
  final number = content['number'];
  if (number is! int) {
    throw const SymphonyFailure(
      'github_unknown_payload',
      'GitHub issue number is missing.',
    );
  }
  final repositoryName = nameWithOwner.split('/').last;
  return SymphonyIssue(
    id: _requiredString(node['id'], 'id'),
    identifier: '$repositoryName#$number',
    title: _requiredString(content['title'], 'content.title'),
    description: _nullableString(content['body']),
    priority: _normalizePriority(node['priorityValue']),
    state: _singleSelectName(node['status']) ?? '',
    branchName: 'issue-$number',
    url: _nullableString(content['url']),
    labels: _normalizeLabels(content['labels']),
    blockedBy: _normalizeBlockers(content['blockedBy']),
    createdAt: _parseDate(content['createdAt']),
    updatedAt:
        _parseDate(content['updatedAt']) ?? _parseDate(node['updatedAt']),
  );
}

String _requiredString(Object? value, String field) {
  if (value is String) return value;
  throw SymphonyFailure(
    'github_unknown_payload',
    'Missing issue field $field.',
  );
}

String? _nullableString(Object? value) => value is String ? value : null;

DateTime? _parseDate(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

List<String> _normalizeLabels(Object? labels) {
  if (labels is! Map || labels['nodes'] is! List) return const [];
  return (labels['nodes'] as List)
      .whereType<Map>()
      .map((label) => label['name'])
      .whereType<String>()
      .map((name) => name.toLowerCase())
      .toList(growable: false);
}

String? _singleSelectName(Object? fieldValue) {
  if (fieldValue is! Map) return null;
  return _nullableString(fieldValue['name']);
}

int? _normalizePriority(Object? fieldValue) {
  final name = _singleSelectName(fieldValue);
  if (name == null) return null;
  final match = RegExp(r'^P(\d+)$', caseSensitive: false).firstMatch(name);
  return match == null ? null : int.tryParse(match.group(1)!);
}

List<IssueBlocker> _normalizeBlockers(Object? blockedBy) {
  if (blockedBy is! Map || blockedBy['nodes'] is! List) return const [];
  final blockers = <IssueBlocker>[];
  for (final issue in (blockedBy['nodes'] as List).whereType<Map>()) {
    final repository = issue['repository'];
    final repositoryName = repository is Map
        ? _nullableString(repository['nameWithOwner'])?.split('/').last
        : null;
    final number = issue['number'];
    final identifier = repositoryName != null && number is int
        ? '$repositoryName#$number'
        : null;
    blockers.add(
      IssueBlocker(
        id: _nullableString(issue['id']),
        identifier: identifier,
        state: issue['state'] == 'CLOSED' ? 'Done' : 'Open',
      ),
    );
  }
  return blockers;
}

const _candidateQuery = r'''
query SymphonyCandidateIssues(
  $owner: String!
  $projectNumber: Int!
  $first: Int!
  $after: String
  $statusField: String!
  $priorityField: String!
) {
  user(login: $owner) {
    projectV2(number: $projectNumber) {
      items(first: $first, after: $after) {
        nodes {
          ...SymphonyProjectItem
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}

fragment SymphonyProjectItem on ProjectV2Item {
  id
  updatedAt
  status: fieldValueByName(name: $statusField) {
    ... on ProjectV2ItemFieldSingleSelectValue { name }
  }
  priorityValue: fieldValueByName(name: $priorityField) {
    ... on ProjectV2ItemFieldSingleSelectValue { name }
  }
  content {
    ... on Issue {
      id
      number
      title
      body
      url
      createdAt
      updatedAt
      repository { nameWithOwner }
      labels(first: 50) { nodes { name } }
      blockedBy(first: 20) {
        nodes {
          id
          number
          state
          repository { nameWithOwner }
        }
      }
    }
  }
}
''';

const _issueStateQuery = r'''
query SymphonyIssueStates(
  $ids: [ID!]!
  $statusField: String!
  $priorityField: String!
) {
  nodes(ids: $ids) {
    ... on ProjectV2Item {
      ...SymphonyProjectItem
    }
  }
}

fragment SymphonyProjectItem on ProjectV2Item {
  id
  updatedAt
  status: fieldValueByName(name: $statusField) {
    ... on ProjectV2ItemFieldSingleSelectValue { name }
  }
  priorityValue: fieldValueByName(name: $priorityField) {
    ... on ProjectV2ItemFieldSingleSelectValue { name }
  }
  content {
    ... on Issue {
      id
      number
      title
      body
      url
      createdAt
      updatedAt
      repository { nameWithOwner }
      labels(first: 50) { nodes { name } }
      blockedBy(first: 20) {
        nodes {
          id
          number
          state
          repository { nameWithOwner }
        }
      }
    }
  }
}
''';
