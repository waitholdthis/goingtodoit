# Release Guide — GoingToDoIt

This document covers building production-signed releases. All commands run from
`goingtodoit_app/`.

## Toolchain

- **Flutter:** stable 3.44.3 (`~/flutter`)
- **JDK:** Temurin 17 (`~/jdk`)
- **Android SDK:** `~/android-sdk` (platform 36, build-tools 36.0.0, platform-tools)

For convenience, `source ../.devenv.sh` (git-ignored) puts the whole toolchain
on `PATH` and sets `JAVA_HOME` / `ANDROID_SDK_ROOT`.

## Android — production release

### 1. Create an upload keystore (one time)

The keystore is your app's permanent signing identity. **Back it up securely —
if you lose it you cannot publish updates** (unless enrolled in Play App
Signing key reset).

```bash
keytool -genkey -v \
  -keystore ~/goingtodoit-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Choose a strong password when prompted.

### 2. Create `android/key.properties`

This file is git-ignored (see `.gitignore`) and must never be committed.

```properties
storePassword=<password from step 1>
keyPassword=<password from step 1>
keyAlias=upload
storeFile=/home/waitholdthis/goingtodoit-upload.jks
```

`android/app/build.gradle.kts` reads this automatically. If the file is absent,
the build falls back to debug signing (useful for local testing, **not**
distributable).

### 3. Build

```bash
flutter build appbundle --release   # -> build/app/outputs/bundle/release/app-release.aab  (Play Store)
flutter build apk --release         # -> build/app/outputs/flutter-apk/app-release.apk     (sideload/testing)
```

Upload the `.aab` to the Play Console.

## iOS — production release

iOS **cannot be built on Linux**; it requires macOS + Xcode. The iOS project
under `ios/` is configured and builds via CI (`flutter build ios --no-codesign`).
For a signed App Store release, on a Mac:

```bash
flutter build ipa --release
```

then upload `build/ios/ipa/*.ipa` via Xcode/Transporter. You will need an Apple
Developer account, a distribution certificate, and a provisioning profile.

## Versioning

Bump `version:` in `pubspec.yaml` (`<versionName>+<versionCode>`) before each
release. The `versionCode` (the `+N` part) must increase for every Play Store
upload.

## CI

`.github/workflows/ci.yml` runs format-check, analyze, tests, an Android debug
APK build, and an iOS no-codesign build on every push/PR to `main`.
```
