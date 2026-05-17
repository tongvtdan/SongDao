#!/bin/sh
set -eu

if [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  exit 0
fi

if [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ] || [ "${CODE_SIGNING_REQUIRED:-YES}" = "NO" ]; then
  exit 0
fi

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
  echo "warning: No code signing identity available for native assets."
  exit 0
fi

frameworks_dir="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
if [ ! -d "$frameworks_dir" ]; then
  exit 0
fi

project_root="${SRCROOT:-}/.."

platform_for_binary() {
  otool -l "$1" | awk '/LC_BUILD_VERSION/{in_build=1} in_build && $1 == "platform" {print $2; exit}'
}

device_artifact_for_framework() {
  framework_name="$1"
  case "$framework_name" in
    objective_c) artifact_name="objective_c.dylib" ;;
    sqlite3) artifact_name="libsqlite3.dylib" ;;
    *) return 1 ;;
  esac

  find "$project_root/.dart_tool/hooks_runner/shared" -name "$artifact_name" -type f 2>/dev/null | while IFS= read -r candidate; do
    case " $(lipo -archs "$candidate") " in
      *" arm64 "*) ;;
      *) continue ;;
    esac

    if [ "$(platform_for_binary "$candidate")" = "2" ]; then
      echo "$candidate"
      exit 0
    fi
  done
}

find "$frameworks_dir" -maxdepth 1 -type d -name "*.framework" | while IFS= read -r framework_dir; do
  info_plist="$framework_dir/Info.plist"
  if [ ! -f "$info_plist" ]; then
    continue
  fi

  bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$info_plist" 2>/dev/null || true)
  case "$bundle_id" in
    io.flutter.flutter.native-assets.*) ;;
    *) continue ;;
  esac

  framework_name=$(basename "$framework_dir" .framework)
  binary="$framework_dir/$framework_name"
  if [ ! -f "$binary" ]; then
    continue
  fi

  binary_archs=$(lipo -archs "$binary")
  for arch in $binary_archs; do
    case " ${ARCHS:-} " in
      *" $arch "*) ;;
      *)
        echo "Stripping $arch from $framework_name.framework"
        lipo -remove "$arch" -output "$binary" "$binary"
        ;;
    esac
  done

  binary_platform=$(platform_for_binary "$binary")
  if [ "$binary_platform" != "2" ]; then
    device_artifact=$(device_artifact_for_framework "$framework_name" | head -n 1)
    if [ -z "$device_artifact" ]; then
      echo "error: $framework_name.framework is platform $binary_platform, but no device native asset was found."
      exit 1
    fi

    echo "Replacing $framework_name.framework binary with device native asset"
    cp "$device_artifact" "$binary"
    chmod +x "$binary"
  fi

  echo "Code signing $framework_name.framework"
  /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" ${OTHER_CODE_SIGN_FLAGS:-} "$framework_dir"
done
