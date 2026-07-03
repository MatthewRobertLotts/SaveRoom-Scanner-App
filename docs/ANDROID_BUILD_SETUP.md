# Android Build Setup

Tags: #type/reference

## Overview

This doc records how the Android SDK was set up on the secondary drive for debug APK builds.

## SDK Locations

| Item | Path |
|------|------|
| Android SDK root | `/media/matt/Storage/DevTools/android-sdk` |
| Flutter SDK | `/media/matt/Storage/DevTools/flutter` |
| Gradle cache | `/media/matt/Storage/DevCaches/gradle` |
| Android user cache | `/media/matt/Storage/DevCaches/android-user` |
| Dart pub cache | `/media/matt/Storage/DevCaches/dart-pub-cache` |
| Java/JDK | OpenJDK 17 (system package) |

## Packages Installed

- `platform-tools` (adb, fastboot)
- `platforms;android-36` (for Flutter 3.44.4 compatibility)
- `build-tools;36.0.0`
- NDK 28.2.13676358 (auto-installed by Flutter)
- CMake 3.22.1 (auto-installed by Flutter)

## Flutter Config

```bash
flutter config --android-sdk /media/matt/Storage/DevTools/android-sdk
```

## Build Commands

```bash
export ANDROID_SDK_ROOT=/media/matt/Storage/DevTools/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export GRADLE_USER_HOME=/media/matt/Storage/DevCaches/gradle
export ANDROID_USER_HOME=/media/matt/Storage/DevCaches/android-user
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

## What Is Not Committed

- `build/` directory (APK, intermediates) — in `.gitignore`
- `.dart_tool/` — in `.gitignore`
- Android SDK files — outside repo
- Gradle caches — outside repo
- No keystores, secrets, or API keys

## Remaining Blockers

- `flutter build apk --release` needs a signing key/keystore
- Chrome web runtime not installed (web testing)
- Linux desktop build deps not installed (clang++, cmake, ninja, GTK 3 dev)

## Device Install

To install on a connected phone via USB:

```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-debug.apk
```

No phone was connected at setup time — device install not tested.

## Links

- [README.md](../README.md)
- [ROADMAP.md](ROADMAP.md)