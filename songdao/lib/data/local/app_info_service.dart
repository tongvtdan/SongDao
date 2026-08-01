import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppVersionInfo {
  const AppVersionInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  String get displayValue {
    if (buildNumber.isEmpty) {
      return version;
    }
    return '$version ($buildNumber)';
  }
}

class AppInfoService {
  const AppInfoService({this._channel = const MethodChannel(_channelName)});

  static const _channelName = 'app.songdao/app_info';

  final MethodChannel _channel;

  Future<AppVersionInfo> versionInfo() async {
    try {
      final result = await _channel.invokeMapMethod<String, String>(
        'getVersionInfo',
      );
      return AppVersionInfo(
        version: result?['version'] ?? '0.1.0',
        buildNumber: result?['buildNumber'] ?? '3',
      );
    } on PlatformException catch (error, stackTrace) {
      _logAppInfoError(error, stackTrace);
    } on MissingPluginException catch (error, stackTrace) {
      _logAppInfoError(error, stackTrace);
    }

    return const AppVersionInfo(version: '0.1.0', buildNumber: '3');
  }

  void _logAppInfoError(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('App info bridge failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
