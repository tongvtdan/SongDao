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
      String apiKey,
      String query,
      Map<String, Object?> variables,
    );

class LinearIssueTrackerClient implements IssueTrackerClient {
  LinearIssueTrackerClient({required this.config, GraphQlPoster? poster})
    : _poster = poster ?? _defaultPoster;

  final SymphonyConfig config;
  final GraphQlPoster _poster;

  @override
  Future<List<SymphonyIssue>> fetchCandidateIssues() {
    return _fetchIssuesByFilter(
      states: config.tracker.activeStates,
      includeProject: true,
    );
  }

  @override
  Future<List<SymphonyIssue>> fetchIssuesByStates(List<String> stateNames) {
    if (stateNames.isEmpty) return Future.value(const []);
    return _fetchIssuesByFilter(states: stateNames, includeProject: true);
  }

  @override
  Future<List<SymphonyIssue>> fetchIssueStatesByIds(
    List<String> issueIds,
  ) async {
    if (issueIds.isEmpty) return const [];
    final response = await _post(_issueStateQuery, {'ids': issueIds});
    final nodes = _connectionNodes(response, ['data', 'issues']);
    return nodes.map(_normalizeIssue).toList(growable: false);
  }

  Future<List<SymphonyIssue>> _fetchIssuesByFilter({
    required List<String> states,
    required bool includeProject,
  }) async {
    final all = <SymphonyIssue>[];
    String? cursor;
    while (true) {
      final response = await _post(_candidateQuery, {
        'projectSlug': config.tracker.projectSlug,
        'states': states,
        'after': cursor,
        'first': 50,
      });
      final issues = _getPath(response, ['data', 'issues']);
      if (issues is! Map) {
        throw const SymphonyFailure(
          'linear_unknown_payload',
          'Linear response did not include issues connection.',
        );
      }
      all.addAll(
        _connectionNodes(response, ['data', 'issues']).map(_normalizeIssue),
      );
      final pageInfo = issues['pageInfo'];
      if (pageInfo is! Map) {
        throw const SymphonyFailure(
          'linear_unknown_payload',
          'Linear response did not include pageInfo.',
        );
      }
      final hasNextPage = pageInfo['hasNextPage'] == true;
      if (!hasNextPage) break;
      final endCursor = pageInfo['endCursor'];
      if (endCursor is! String || endCursor.isEmpty) {
        throw const SymphonyFailure(
          'linear_missing_end_cursor',
          'Linear pagination did not return endCursor.',
        );
      }
      cursor = endCursor;
    }
    return all;
  }

  Future<Map<String, Object?>> _post(
    String query,
    Map<String, Object?> variables,
  ) async {
    final apiKey = config.tracker.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw const SymphonyFailure(
        'missing_tracker_api_key',
        'Linear API key is required.',
      );
    }
    try {
      final response = await _poster(
        config.tracker.endpoint,
        apiKey,
        query,
        variables,
      );
      final errors = response['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw SymphonyFailure(
          'linear_graphql_errors',
          'Linear GraphQL returned ${errors.length} error(s).',
        );
      }
      return response;
    } on SymphonyFailure {
      rethrow;
    } catch (error) {
      throw SymphonyFailure('linear_api_request', error.toString());
    }
  }

  static Future<Map<String, Object?>> _defaultPoster(
    String endpoint,
    String apiKey,
    String query,
    Map<String, Object?> variables,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, apiKey);
      request.write(jsonEncode({'query': query, 'variables': variables}));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw SymphonyFailure(
          'linear_api_status',
          'Linear returned HTTP ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      throw const SymphonyFailure(
        'linear_unknown_payload',
        'Linear response body was not a JSON object.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

List<Map<String, Object?>> _connectionNodes(
  Map<String, Object?> response,
  List<String> path,
) {
  final connection = _getPath(response, path);
  if (connection is! Map) {
    throw const SymphonyFailure(
      'linear_unknown_payload',
      'Expected a Linear connection object.',
    );
  }
  final nodes = connection['nodes'];
  if (nodes is! List) {
    throw const SymphonyFailure(
      'linear_unknown_payload',
      'Expected Linear connection nodes.',
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

SymphonyIssue _normalizeIssue(Map<String, Object?> node) {
  final state = node['state'];
  final labels = node['labels'];
  final relations = node['relations'];
  final inverseRelations = node['inverseRelations'];
  return SymphonyIssue(
    id: _requiredString(node['id'], 'id'),
    identifier: _requiredString(node['identifier'], 'identifier'),
    title: _requiredString(node['title'], 'title'),
    description: _nullableString(node['description']),
    priority: node['priority'] is int ? node['priority'] as int : null,
    state: state is Map ? _requiredString(state['name'], 'state.name') : '',
    branchName: _nullableString(node['branchName']),
    url: _nullableString(node['url']),
    labels: _normalizeLabels(labels),
    blockedBy: _normalizeBlockers(inverseRelations ?? relations),
    createdAt: _parseDate(node['createdAt']),
    updatedAt: _parseDate(node['updatedAt']),
  );
}

String _requiredString(Object? value, String field) {
  if (value is String) return value;
  throw SymphonyFailure(
    'linear_unknown_payload',
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

List<IssueBlocker> _normalizeBlockers(Object? relations) {
  if (relations is! Map || relations['nodes'] is! List) return const [];
  final blockers = <IssueBlocker>[];
  for (final relation in (relations['nodes'] as List).whereType<Map>()) {
    if (relation['type'] != 'blocks') continue;
    final related = relation['issue'] ?? relation['relatedIssue'];
    if (related is! Map) continue;
    final state = related['state'];
    blockers.add(
      IssueBlocker(
        id: _nullableString(related['id']),
        identifier: _nullableString(related['identifier']),
        state: state is Map ? _nullableString(state['name']) : null,
      ),
    );
  }
  return blockers;
}

const _candidateQuery = r'''
query SymphonyCandidateIssues(
  $projectSlug: String!
  $states: [String!]
  $first: Int!
  $after: String
) {
  issues(
    first: $first
    after: $after
    filter: {
      project: { slugId: { eq: $projectSlug } }
      state: { name: { in: $states } }
    }
    orderBy: createdAt
  ) {
    nodes {
      id
      identifier
      title
      description
      priority
      branchName
      url
      createdAt
      updatedAt
      state { name }
      labels { nodes { name } }
      inverseRelations {
        nodes {
          type
          issue { id identifier state { name } }
        }
      }
    }
    pageInfo { hasNextPage endCursor }
  }
}
''';

const _issueStateQuery = r'''
query SymphonyIssueStates($ids: [ID!]!) {
  issues(filter: { id: { in: $ids } }) {
    nodes {
      id
      identifier
      title
      description
      priority
      branchName
      url
      createdAt
      updatedAt
      state { name }
      labels { nodes { name } }
      inverseRelations {
        nodes {
          type
          issue { id identifier state { name } }
        }
      }
    }
    pageInfo { hasNextPage endCursor }
  }
}
''';
