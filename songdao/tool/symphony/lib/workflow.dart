import 'dart:io';

import 'models.dart';

class WorkflowLoader {
  const WorkflowLoader();

  Future<WorkflowDefinition> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const SymphonyFailure(
        'missing_workflow_file',
        'Workflow file does not exist.',
      );
    }

    final text = await file.readAsString();
    return parse(text);
  }

  WorkflowDefinition parse(String text) {
    final normalized = text.replaceAll('\r\n', '\n');
    if (!normalized.startsWith('---\n') && normalized.trim() != '---') {
      return WorkflowDefinition(
        config: const {},
        promptTemplate: normalized.trim(),
      );
    }

    final lines = normalized.split('\n');
    var closingIndex = -1;
    for (var i = 1; i < lines.length; i += 1) {
      if (lines[i].trim() == '---') {
        closingIndex = i;
        break;
      }
    }

    if (closingIndex == -1) {
      throw const SymphonyFailure(
        'workflow_parse_error',
        'YAML front matter was opened but not closed.',
      );
    }

    final frontMatter = lines.sublist(1, closingIndex).join('\n');
    final body = lines.sublist(closingIndex + 1).join('\n').trim();
    final parsed = const _TinyYamlParser().parse(frontMatter);
    if (parsed is! Map<String, Object?>) {
      throw const SymphonyFailure(
        'workflow_front_matter_not_a_map',
        'Workflow front matter must be a YAML map.',
      );
    }

    return WorkflowDefinition(config: parsed, promptTemplate: body);
  }
}

class WorkflowPathResolver {
  const WorkflowPathResolver();

  String resolve(List<String> args, {String? cwd}) {
    final positional = args.where((arg) => !arg.startsWith('--')).toList();
    final selected = positional.isEmpty ? 'WORKFLOW.md' : positional.first;
    final base = cwd ?? Directory.current.path;
    final uri = Uri.file(selected);
    if (uri.isAbsolute) {
      return uri.toFilePath();
    }
    return Uri.file('$base/').resolve(selected).toFilePath();
  }
}

class _TinyYamlParser {
  const _TinyYamlParser();

  Object? parse(String source) {
    final lines = source.split('\n');
    if (lines.where((line) => _isContent(line)).isEmpty) {
      return <String, Object?>{};
    }
    if (_firstContent(lines).trim().startsWith('-')) {
      return _parseList(lines, 0, 0).value;
    }
    return _parseMap(lines, 0, 0).value;
  }

  _ParseResult<Map<String, Object?>> _parseMap(
    List<String> lines,
    int index,
    int indent,
  ) {
    final map = <String, Object?>{};
    var i = index;
    while (i < lines.length) {
      final line = lines[i];
      if (!_isContent(line)) {
        i += 1;
        continue;
      }
      final currentIndent = _indentOf(line);
      if (currentIndent < indent) break;
      if (currentIndent > indent) {
        throw SymphonyFailure(
          'workflow_parse_error',
          'Unexpected indentation at line ${i + 1}.',
        );
      }

      final trimmed = line.trimRight().trimLeft();
      final separator = trimmed.indexOf(':');
      if (separator <= 0) {
        throw SymphonyFailure(
          'workflow_parse_error',
          'Expected key/value pair at line ${i + 1}.',
        );
      }

      final key = trimmed.substring(0, separator).trim();
      final rest = trimmed.substring(separator + 1).trim();
      if (rest == '|') {
        final block = _parseBlockScalar(lines, i + 1, indent + 2);
        map[key] = block.value;
        i = block.nextIndex;
      } else if (rest.isEmpty) {
        final next = _nextContentIndex(lines, i + 1);
        if (next == null || _indentOf(lines[next]) <= indent) {
          map[key] = <String, Object?>{};
          i += 1;
        } else if (lines[next].trimLeft().startsWith('-')) {
          final child = _parseList(lines, next, _indentOf(lines[next]));
          map[key] = child.value;
          i = child.nextIndex;
        } else {
          final child = _parseMap(lines, next, _indentOf(lines[next]));
          map[key] = child.value;
          i = child.nextIndex;
        }
      } else {
        map[key] = _parseScalar(rest);
        i += 1;
      }
    }
    return _ParseResult(map, i);
  }

  _ParseResult<List<Object?>> _parseList(
    List<String> lines,
    int index,
    int indent,
  ) {
    final values = <Object?>[];
    var i = index;
    while (i < lines.length) {
      final line = lines[i];
      if (!_isContent(line)) {
        i += 1;
        continue;
      }
      final currentIndent = _indentOf(line);
      if (currentIndent < indent) break;
      if (currentIndent != indent || !line.trimLeft().startsWith('-')) {
        break;
      }
      final value = line.trimLeft().substring(1).trim();
      values.add(_parseScalar(value));
      i += 1;
    }
    return _ParseResult(values, i);
  }

  _ParseResult<String> _parseBlockScalar(
    List<String> lines,
    int index,
    int indent,
  ) {
    final buffer = StringBuffer();
    var i = index;
    while (i < lines.length) {
      final line = lines[i];
      if (_isContent(line) && _indentOf(line) < indent) break;
      if (line.length >= indent) {
        buffer.writeln(line.substring(indent));
      } else {
        buffer.writeln();
      }
      i += 1;
    }
    return _ParseResult(buffer.toString().trimRight(), i);
  }

  Object? _parseScalar(String value) {
    if (value.isEmpty) return '';
    if (value == 'null' || value == '~') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;
    if (value.startsWith('[') && value.endsWith(']')) {
      final inner = value.substring(1, value.length - 1).trim();
      if (inner.isEmpty) return <Object?>[];
      return inner.split(',').map((part) => _parseScalar(part.trim())).toList();
    }
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  bool _isContent(String line) {
    final trimmed = line.trim();
    return trimmed.isNotEmpty && !trimmed.startsWith('#');
  }

  String _firstContent(List<String> lines) {
    return lines.firstWhere(_isContent, orElse: () => '');
  }

  int? _nextContentIndex(List<String> lines, int start) {
    for (var i = start; i < lines.length; i += 1) {
      if (_isContent(lines[i])) return i;
    }
    return null;
  }

  int _indentOf(String line) {
    var count = 0;
    while (count < line.length && line.codeUnitAt(count) == 32) {
      count += 1;
    }
    return count;
  }
}

class _ParseResult<T> {
  const _ParseResult(this.value, this.nextIndex);

  final T value;
  final int nextIndex;
}
