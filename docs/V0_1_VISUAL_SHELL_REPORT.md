# v0.1 Visual Shell Report

Tags: #type/project

## Overview

The SaveRoom Scanner App now has a cleaner fixture-first visual shell. This milestone only improves frontend UI polish and keeps the app separate from the v12.2.0 API backend.

## Body

### Completed

- Dark Material 3 theme with rounded cards and scanner-app feel.
- Better Home screen with baseline/mode badges and roadmap status.
- Better Scanner placeholder with scan-frame visual and mock scan action.
- Better Mock Scan Result screen using fixture data defensively.
- Better Card Detail screen showing card facts, image URL placeholder, pricing/evidence, commercial/SKU info, source/provenance, and raw fixture debug.
- Better Collection placeholder with mock zero-state stats and v12.4 plan.
- Better Settings/dev screen with app version, API baseline, fixture mode, planned milestones, and storage note.
- Reusable widgets: `StatusPill`, `FixtureBadge`, `SectionCard`, `PrimaryActionCard`.

### Validation

```text
dart format lib test: passed
flutter pub get: passed
flutter analyze: passed
flutter test: passed
flutter build web --debug: passed
```

### Boundaries kept

- Fixture mode remains default.
- Real API mode was planned-only at v0.1. See v0.2 report for the current state.
- No real backend calls on startup.
- No auth, billing, camera/OCR, provider calls, marketplace calls, or app-store publishing.
- API baseline remains `v12.2.0`.

### Remaining blocker

Android APK build is still blocked by missing Android SDK. Chrome runtime and Linux desktop builds still need their own toolchain dependencies if Matthew wants those targets.

### Next (completed in v0.2)

Real local API read mode was delivered as v0.2. See:

- [V0_2_REAL_LOCAL_API_MODE_REPORT.md](V0_2_REAL_LOCAL_API_MODE_REPORT.md)
- [ROADMAP.md](ROADMAP.md)

## Links

- Related: [../README.md](../README.md)
- Related: [APP_ARCHITECTURE.md](APP_ARCHITECTURE.md)
- Related: [FIXTURE_MODE.md](FIXTURE_MODE.md)
- Related: [ROADMAP.md](ROADMAP.md)