import 'package:flutter/services.dart';

class SentenceCapitalizationFormatter extends TextInputFormatter {
  const SentenceCapitalizationFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final capitalized = _capitalizeSentenceStarts(newValue.text);
    if (capitalized == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(text: capitalized);
  }

  String _capitalizeSentenceStarts(String text) {
    final buffer = StringBuffer();
    var shouldCapitalize = true;

    for (var i = 0; i < text.length; i += 1) {
      final char = text[i];
      final isLetter = _isLetter(char);

      if (shouldCapitalize && isLetter) {
        buffer.write(char.toUpperCase());
        shouldCapitalize = false;
        continue;
      }

      buffer.write(char);

      if (_endsSentence(char)) {
        shouldCapitalize = true;
      } else if (isLetter || (!shouldCapitalize && char.trim().isNotEmpty)) {
        shouldCapitalize = false;
      } else if (shouldCapitalize && !_keepsSentenceOpen(char)) {
        shouldCapitalize = false;
      }
    }

    return buffer.toString();
  }

  bool _isLetter(String char) => char.toLowerCase() != char.toUpperCase();

  bool _endsSentence(String char) => char == '.' || char == '!' || char == '?';

  bool _keepsSentenceOpen(String char) {
    return char.trim().isEmpty ||
        char == '"' ||
        char == "'" ||
        char == '(' ||
        char == '[' ||
        char == '{';
  }
}
