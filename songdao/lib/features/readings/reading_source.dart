import 'package:webview_flutter/webview_flutter.dart';

enum ReadingSource {
  ktcgkpvMassReading(
    id: 'ktcgkpv_mass_reading',
    url: 'https://ktcgkpv.org/readings/mass-reading',
    requiresJavaScript: false,
  );

  const ReadingSource({
    required this.id,
    required this.url,
    required this.requiresJavaScript,
  });

  final String id;
  final String url;
  final bool requiresJavaScript;

  Uri get uri => Uri.parse(url);

  static const approvedHosts = {'ktcgkpv.org'};

  static ReadingSource? fromId(String? id) {
    for (final source in values) {
      if (source.id == id) return source;
    }
    return null;
  }

  static bool isTrustedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.userInfo.isNotEmpty) {
      return false;
    }
    return approvedHosts.contains(uri.host.toLowerCase());
  }
}

NavigationDecision readingNavigationDecision(NavigationRequest request) {
  if (!request.isMainFrame || ReadingSource.isTrustedUrl(request.url)) {
    return NavigationDecision.navigate;
  }
  return NavigationDecision.prevent;
}
