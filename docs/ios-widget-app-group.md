# iOS Widget App Group Setup

SongDao uses a minimal MethodChannel instead of `home_widget` for the first widget bridge.

## Identifiers

- App bundle ID: `com.dantino.songdao`
- Widget bundle ID: `com.dantino.songdao.TodayWidget`
- App Group ID: `group.com.dantino.songdao`
- Widget kind: `SongDaoTodayWidget`
- Flutter channel: `app.songdao/widget_snapshot`
- Shared keys:
  - `latest_widget_snapshot`
  - `latest_widget_snapshot_date`

## Runtime Flow

1. Flutter generates the local `widget_snapshots` JSON from Drift.
2. `WidgetSnapshotBridge.writeLatestSnapshot` sends the latest payload over the iOS MethodChannel.
3. `WidgetSnapshotChannel.swift` writes the payload into App Group `UserDefaults`.
4. `TodayWidget.swift` reads the same App Group payload independently and renders a fallback when missing.
5. The native bridge asks WidgetKit to reload `SongDaoTodayWidget` after a write.

Bridge failures are logged in debug builds on the Dart side and return a failure result instead of throwing into app UI.

## Signing Checklist

Before device or TestFlight builds:

1. In Apple Developer, register `group.com.dantino.songdao` under Identifiers -> App Groups.
2. Enable the App Groups capability for both `com.dantino.songdao` and `com.dantino.songdao.TodayWidget`.
3. Add `group.com.dantino.songdao` to both targets in Xcode Signing & Capabilities.
4. Confirm these entitlement files are assigned:
   - Runner: `Runner/Runner.entitlements`
   - TodayWidget: `TodayWidget/TodayWidget.entitlements`
5. Regenerate provisioning profiles after enabling the App Group.

If the App Group is missing from provisioning, the channel returns `app_group_unavailable` and the widget shows the calm fallback copy.
