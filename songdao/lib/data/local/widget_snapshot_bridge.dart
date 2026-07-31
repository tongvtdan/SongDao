import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetSnapshotBridge {
  const WidgetSnapshotBridge({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const _channelName = 'app.songdao/widget_snapshot';
  static const appGroupId = 'group.com.dantino.songdao';
  static const latestSnapshotKey = 'latest_widget_snapshot';
  static const latestSnapshotDateKey = 'latest_widget_snapshot_date';

  final MethodChannel _channel;

  Future<WidgetSnapshotBridgeResult> writeLatestSnapshot({
    required String date,
    required String payload,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const WidgetSnapshotBridgeResult.skipped('unsupported_platform');
    }

    try {
      final result = await _channel.invokeMethod<bool>('writeLatestSnapshot', {
        'appGroupId': appGroupId,
        'date': date,
        'payload': payload,
      });
      return WidgetSnapshotBridgeResult.success(result ?? false);
    } on PlatformException catch (error, stackTrace) {
      _logBridgeError(error, stackTrace);
      return WidgetSnapshotBridgeResult.failure(error.code, error.message);
    } on MissingPluginException catch (error, stackTrace) {
      _logBridgeError(error, stackTrace);
      return WidgetSnapshotBridgeResult.failure(
        'missing_plugin',
        error.message,
      );
    }
  }

  void _logBridgeError(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('Widget snapshot bridge failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class WidgetSnapshotBridgeResult {
  const WidgetSnapshotBridgeResult._({
    required this.wrote,
    required this.skipped,
    this.code,
    this.message,
  });

  const WidgetSnapshotBridgeResult.success(bool wrote)
    : this._(wrote: wrote, skipped: false);

  const WidgetSnapshotBridgeResult.skipped(String code)
    : this._(wrote: false, skipped: true, code: code);

  const WidgetSnapshotBridgeResult.failure(String code, String? message)
    : this._(wrote: false, skipped: false, code: code, message: message);

  final bool wrote;
  final bool skipped;
  final String? code;
  final String? message;

  bool get failed => !wrote && !skipped;
}
