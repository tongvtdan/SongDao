# iOS build contract

SongDao uses Flutter's Swift Package Manager integration for iOS dependencies.
CocoaPods is not part of the supported build path. Do not recreate `ios/Podfile`,
`ios/Podfile.lock`, or add a Pods project to `ios/Runner.xcworkspace`.

## Supported toolchain

- Flutter 3.44.0 stable or newer
- Dart 3.12.0 or newer (the minimum bundled by Flutter 3.44)
- Xcode 26.6 stable
- iOS deployment target 15.0 for Runner, TodayWidget, and RunnerTests

The Flutter and Dart floors are also enforced by `pubspec.yaml`. Release and
CI builds must use a Flutter SDK that satisfies those constraints.

Flutter generates the plugin package under `ios/Flutter/ephemeral/` during a
build. That directory is generated and ignored; the Xcode project reference to
`FlutterGeneratedPluginSwiftPackage` is the checked-in integration point.

## Local and CI gate

Run this from the repository root after changing Flutter, Xcode, or a native
plugin:

```sh
set -euo pipefail

test "$(xcodebuild -version | awk 'NR == 1 { print $2 }')" = "26.6"
flutter --version
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --debug --no-codesign
```

If the Xcode check fails, select the stable installation explicitly before
running the gate:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

The build must use `ios/Runner.xcodeproj` with Swift Package Manager and must
not report CocoaPods integration or deployment targets below iOS 15.0.
