import Flutter
import UIKit

final class IconChannel {
  private static let channelName = "app.songdao/icon"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "supportsAlternateIcons":
        result(UIApplication.shared.supportsAlternateIcons)
      case "setIcon":
        setIcon(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func setIcon(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let iconName = arguments["iconName"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "Missing iconName.", details: nil))
      return
    }

    let resolvedIconName = iconName == "primary" ? nil : iconName
    UIApplication.shared.setAlternateIconName(resolvedIconName) { error in
      if let error = error {
        result(FlutterError(code: "icon_error", message: error.localizedDescription, details: iconName))
      } else {
        result(nil)
      }
    }
  }
}
