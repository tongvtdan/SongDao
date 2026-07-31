# Android release identity and signing

SongDao's production Android identity is `com.dantino.songdao`. Keep this
application ID stable after the first Play release; changing it creates a new
app instead of updating the existing one. The custom URI scheme remains
`songdao`, so notification and deep-link routing do not change between debug
and release builds.

## Local setup

Create an upload keystore outside the repository:

```sh
mkdir -p "$HOME/.songdao"
keytool -genkeypair -v \
  -keystore "$HOME/.songdao/songdao-upload-key.jks" \
  -storetype JKS \
  -alias songdao-upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Copy `android/key.properties.example` to `android/key.properties` and set:

```properties
storeFile=/absolute/path/to/songdao-upload-key.jks
storePassword=the-keystore-password
keyAlias=songdao-upload
keyPassword=the-key-password
```

The Gradle build reads `android/key.properties` only locally. It also accepts
these environment variables, which are intended for CI:

| Property | Environment variable |
| --- | --- |
| `storeFile` | `SONGDAO_STORE_FILE` |
| `storePassword` | `SONGDAO_STORE_PASSWORD` |
| `keyAlias` | `SONGDAO_KEY_ALIAS` |
| `keyPassword` | `SONGDAO_KEY_PASSWORD` |

Release tasks fail if any signing value is missing. Debug and profile builds do
not require release credentials.

## CI setup

Store the keystore as a base64-encoded CI secret and write it to a temporary
runner path before building. Keep the passwords in separate masked secrets:

```sh
set -euo pipefail

keystore_path="$RUNNER_TEMP/songdao-upload-key.jks"
printf '%s' "$SONGDAO_KEYSTORE_BASE64" | base64 --decode > "$keystore_path"
export SONGDAO_STORE_FILE="$keystore_path"
export SONGDAO_STORE_PASSWORD="$SONGDAO_STORE_PASSWORD_SECRET"
export SONGDAO_KEY_ALIAS="$SONGDAO_KEY_ALIAS_SECRET"
export SONGDAO_KEY_PASSWORD="$SONGDAO_KEY_PASSWORD_SECRET"

flutter build appbundle --release
```

The keystore file should be removed by the CI runner after the job. Do not
print signing variables or include them in build logs.

## Key rotation

Use Google Play App Signing for the long-lived app-signing key. The keystore
used here should be the Play upload key, not the app-signing key. When rotating
it, generate a new upload key, register its certificate in Play Console, then
replace the CI secret and each developer's local keystore reference. Keep the
old upload key secured until Play confirms the new key is active. If an upload
key is lost, use Play Console's upload-key reset flow; never change
`applicationId` as a recovery step.

## Verification

With signing configured, run:

```sh
flutter build appbundle --release
flutter build apk --release
flutter test
```

Inspect the APK or AAB with Android build tools and confirm the package is
`com.dantino.songdao`, the version matches `pubspec.yaml`, and the merged
manifest still contains the notification receivers and `songdao` URI intent
filter.
