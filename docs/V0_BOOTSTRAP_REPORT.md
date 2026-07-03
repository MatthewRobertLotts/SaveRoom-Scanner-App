# v0 Bootstrap Report

Tags: #type/project

## Overview

This report records the SaveRoom Scanner App bootstrap and first Flutter validation pass. Flutter/Dart are now installed on the secondary drive and the repo has generated Flutter project files plus the existing fixture-mode shell.

## Body

### Built

- Separate app repo at `/media/matt/Storage/Brain/SaveRoom-Scanner-App`.
- Git repo on `main`.
- Minimal Flutter source skeleton for fixture-mode home, scanner placeholder, mock scan result, card detail, collection placeholder, and settings screens.
- Sanitized v12.2.0 fixture files copied into `assets/fixtures/v12_2_pos/`.
- Docs for architecture, API integration, fixture mode, roadmap, and bootstrap status.

### Validation

- Flutter SDK: `/media/matt/Storage/DevTools/flutter`
- Dart SDK: bundled with Flutter
- `flutter pub get`: passed
- `flutter analyze`: passed
- `flutter test`: passed
- `flutter build web --debug`: passed

### Remaining blocker

Android APK builds are blocked because Flutter doctor cannot locate an Android SDK. Android Studio/SDK/system package installation was not attempted.

### Next

Improve the visual app shell and card detail UI, or approve Android SDK/toolchain setup on secondary-drive storage if Android APK validation is required.


### v0.1 visual shell polish

Completed after Flutter validation:

- Improved dark Material 3 theme.
- Improved Home, Scanner, Mock Scan Result, Card Detail, Collection, and Settings screens.
- Added small reusable UI widgets: `StatusPill`, `FixtureBadge`, `SectionCard`, and `PrimaryActionCard`.
- Fixture mode remains default; real API mode remains explicit and unimplemented.
- No auth, billing, camera/OCR, provider calls, or app-store publishing.
- `flutter analyze`, `flutter test`, and `flutter build web --debug` passed.

## Links

- Related: [../README.md](../README.md)
- Related: [ROADMAP.md](ROADMAP.md)
