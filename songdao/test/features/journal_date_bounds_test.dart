import 'package:flutter_test/flutter_test.dart';

import 'package:songdao/features/progress/journal_screen.dart';

void main() {
  test('journal date picker bounds move with the reference year', () {
    final referenceDate = DateTime(2027, 6, 15);

    expect(journalDatePickerFirstDate(referenceDate), DateTime(2017));
    expect(journalDatePickerLastDate(referenceDate), DateTime(2037, 12, 31));
  });
}
