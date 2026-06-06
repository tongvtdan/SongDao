import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/app/sentence_capitalization_formatter.dart';

void main() {
  const formatter = SentenceCapitalizationFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      const TextEditingValue(),
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }

  test(
    'capitalizes the first letter and letters after sentence punctuation',
    () {
      expect(
        format('xin chào. hôm nay cầu nguyện? amen! bình an').text,
        'Xin chào. Hôm nay cầu nguyện? Amen! Bình an',
      );
    },
  );

  test('keeps existing casing outside sentence starts', () {
    expect(
      format('xin Chúa gìn giữ Maria. amen').text,
      'Xin Chúa gìn giữ Maria. Amen',
    );
  });

  test('does not change active composing text', () {
    const value = TextEditingValue(
      text: 'xin chao',
      composing: TextRange(start: 0, end: 3),
    );

    expect(formatter.formatEditUpdate(const TextEditingValue(), value), value);
  });
}
