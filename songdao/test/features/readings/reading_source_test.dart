import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:songdao/features/readings/reading_source.dart';

void main() {
  group('ReadingSource', () {
    test('resolves the typed source identifier', () {
      expect(
        ReadingSource.fromId('ktcgkpv_mass_reading'),
        ReadingSource.ktcgkpvMassReading,
      );
    });

    test('enables JavaScript for the dynamic reading page', () {
      expect(ReadingSource.ktcgkpvMassReading.requiresJavaScript, isTrue);
    });

    test('rejects missing and unknown source identifiers', () {
      expect(ReadingSource.fromId(null), isNull);
      expect(ReadingSource.fromId('https://example.com'), isNull);
      expect(ReadingSource.fromId('unknown'), isNull);
    });

    test('accepts only HTTPS URLs on approved hosts', () {
      expect(
        ReadingSource.isTrustedUrl(
          'https://ktcgkpv.org/readings/mass-reading?date=2026-07-31',
        ),
        isTrue,
      );
      expect(
        ReadingSource.isTrustedUrl('http://ktcgkpv.org/readings'),
        isFalse,
      );
      expect(
        ReadingSource.isTrustedUrl('https://example.com/readings'),
        isFalse,
      );
      expect(
        ReadingSource.isTrustedUrl('https://ktcgkpv.org@evil.example/readings'),
        isFalse,
      );
      expect(ReadingSource.isTrustedUrl('not a URL'), isFalse);
    });
  });

  group('reading navigation policy', () {
    test('allows trusted main-frame navigation', () {
      expect(
        readingNavigationDecision(
          const NavigationRequest(
            url: 'https://ktcgkpv.org/readings/mass-reading',
            isMainFrame: true,
          ),
        ),
        NavigationDecision.navigate,
      );
    });

    test('blocks external main-frame navigation', () {
      expect(
        readingNavigationDecision(
          const NavigationRequest(
            url: 'https://example.com/phishing',
            isMainFrame: true,
          ),
        ),
        NavigationDecision.prevent,
      );
    });

    test('rejects malformed main-frame navigation', () {
      expect(
        readingNavigationDecision(
          const NavigationRequest(url: 'not a URL', isMainFrame: true),
        ),
        NavigationDecision.prevent,
      );
    });

    test('allows non-main-frame resources to load', () {
      expect(
        readingNavigationDecision(
          const NavigationRequest(
            url: 'https://cdn.example.com/image.png',
            isMainFrame: false,
          ),
        ),
        NavigationDecision.navigate,
      );
    });
  });
}
