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

  echo "Code signing $framework_name.framework"
  /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" ${OTHER_CODE_SIGN_FLAGS:-} "$framework_dir"
done
