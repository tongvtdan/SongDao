import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';
import 'reading_source.dart';

class ReadingWebViewScreen extends StatefulWidget {
  const ReadingWebViewScreen({
    super.key,
    required this.source,
    required this.title,
  });

  final ReadingSource source;
  final String title;

  @override
  State<ReadingWebViewScreen> createState() => _ReadingWebViewScreenState();
}

class _ReadingWebViewScreenState extends State<ReadingWebViewScreen> {
  late final WebViewController _controller;
  var _progress = 0;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(
        widget.source.requiresJavaScript
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setBackgroundColor(AppColors.canvas)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: readingNavigationDecision,
          onProgress: (progress) => setState(() => _progress = progress),
          onPageStarted: (_) => setState(() => _hasError = false),
          onWebResourceError: (_) => setState(() => _hasError = true),
        ),
      )
      ..loadRequest(widget.source.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              minHeight: 2,
              color: AppColors.brand,
              backgroundColor: AppColors.brandSoft,
            ),
          if (_hasError)
            MaterialBanner(
              backgroundColor: AppColors.surfaceSecondary,
              content: const Text(
                'Chưa tải được bài đọc. Kiểm tra kết nối rồi thử lại.',
              ),
              actions: [
                TextButton(
                  onPressed: () => _controller.reload(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
