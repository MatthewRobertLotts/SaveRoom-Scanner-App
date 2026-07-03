# Phone Install Guide

Tags: #type/reference

## Overview

How to install the debug APK on a physical Android phone.

## Prerequisites

1. Enable **Developer Options** on the phone:
   - Settings → About phone → tap "Build number" 7 times
   - Back to Settings → System → Developer options

2. Enable **USB debugging** in Developer Options.

3. Connect phone to PC via USB cable.

4. Authorize the PC on the phone when prompted.

## Check connection

```bash
adb devices
```

Expected output: `<device_id>  device`

If the device shows as `unauthorized`, unlock the phone and accept the RSA key prompt.

## Install

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

The `-r` flag replaces the app if already installed.

## Uninstall

```bash
adb uninstall com.saveroom.saveroom_scanner_app
```

## Important notes

- **Debug build**: this is a development build, not a release build. It includes debug symbols and is larger than a release APK (140MB vs ~15-20MB).
- **No login/billing/camera/OCR yet** — the app runs in fixture mode by default.
- **Fixture mode**: the app works offline with local JSON fixtures. No backend required.
- **Real local API mode**: if you enable real API mode on the phone (`--dart-define=SAVEROOM_FIXTURE_MODE=false`), `127.0.0.1` means the **phone itself**, not the PC. To reach the API on the PC, use the PC's LAN IP:

```bash
flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false \
  --dart-define=SAVEROOM_API_BASE_URL=http://192.168.x.x:8765
```

Find the PC's LAN IP with `ip addr show` or `hostname -I`.

## Links

- [ANDROID_BUILD_SETUP.md](ANDROID_BUILD_SETUP.md)
- [README.md](../README.md)