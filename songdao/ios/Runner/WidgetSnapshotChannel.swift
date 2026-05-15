import Flutter
import Foundation
import WidgetKit

final class WidgetSnapshotChannel {
  private static let channelName = "app.songdao/widget_snapshot"
  private static let latestSnapshotKey = "latest_widget_snapshot"
  private static let latestSnapshotDateKey = "latest_widget_snapshot_date"
  private static let expectedAppGroupId = "group.com.dantino.songdao"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "writeLatestSnapshot":
        writeLatestSnapshot(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func writeLatestSnapshot(call: FlutterMethodCall, result: FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let appGroupId = arguments["appGroupId"] as? String,
      let date = arguments["date"] as? String,
      let payload = arguments["payload"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "Missing appGroupId, date, or payload.", details: nil))
      return
    }

    guard appGroupId == expectedAppGroupId else {
      result(FlutterError(code: "bad_app_group", message: "Unexpected App Group identifier.", details: appGroupId))
      return
    }

    guard let defaults = UserDefaults(suiteName: appGroupId) else {
      result(FlutterError(code: "app_group_unavailable", message: "App Group storage is unavailable.", details: appGroupId))
      return
    }

    defaults.set(payload, forKey: latestSnapshotKey)
    defaults.set(date, forKey: latestSnapshotDateKey)
    let wrote = defaults.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadTimelines(ofKind: "SongDaoTodayWidget")
    }
    result(wrote)
  }
}
