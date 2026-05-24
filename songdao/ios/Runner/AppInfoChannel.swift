import Flutter
import UIKit

final class AppInfoChannel {
  private static let channelName = "app.songdao/app_info"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getVersionInfo":
        let info = Bundle.main.infoDictionary
        result([
          "version": info?["CFBundleShortVersionString"] as? String ?? "",
          "buildNumber": info?["CFBundleVersion"] as? String ?? ""
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
