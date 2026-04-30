import 'models.dart';

class StrictTemplate {
  const StrictTemplate(this.source);

  final String source;

  String render({required SymphonyIssue issue, int? attempt}) {
    return source.replaceAllMapped(RegExp(r'{{\s*([^}]+)\s*}}'), (match) {
      final expression = match.group(1)!.trim();
      if (expression.contains('|')) {
        throw SymphonyFailure(
          'template_render_error',
          'Unknown filters are not allowed: $expression.',
        );
      }
      final value = _resolve(expression, issue, attempt);
      if (value == null) {
        throw SymphonyFailure(
          'template_render_error',
          'Unknown template variable: $expression.',
        );
      }
      return value.toString();
    });
  }

  Object? _resolve(String path, SymphonyIssue issue, int? attempt) {
    if (path == 'attempt') return attempt;
    if (!path.startsWith('issue.')) return null;
    switch (path.substring('issue.'.length)) {
      case 'id':
        return issue.id;
      case 'identifier':
        return issue.identifier;
      case 'title':
        return issue.title;
      case 'description':
        return issue.description;
      case 'priority':
        return issue.priority;
      case 'state':
        return issue.state;
      case 'branch_name':
        return issue.branchName;
      case 'url':
        return issue.url;
      case 'labels':
        return issue.labels.join(', ');
      case 'created_at':
        return issue.createdAt?.toIso8601String();
      case 'updated_at':
        return issue.updatedAt?.toIso8601String();
      default:
        return null;
    }
  }
}
