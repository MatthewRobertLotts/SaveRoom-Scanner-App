# SaveRoom Scanner App — v0.2 Real Local API Read Mode

Tags: #type/report #save-room-scanner

## Overview

v0.2 adds real local API read mode to the SaveRoom Scanner App, using the released v12.2.0 API endpoints at `http://127.0.0.1:8765`. Fixture mode remains the default. Real local API mode is opt-in via `dart-define`.

## What changed

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `http: ^1.6.0` dependency |
| `lib/services/saveroom_api_client.dart` | Implemented `getCardDetail()` and `getHealth()` real API HTTP methods; kept fixture mode as default; http.Client injection for testability |
| `lib/features/cards/card_detail_screen.dart` | Uses `SaveRoomApiClient` instead of direct `FixtureLoader`; shows live API mode chip or fixture badge; graceful error/fallback guidance |
| `lib/features/settings/settings_screen.dart` | Shows real API mode status (opt-in/active); added user-triggered health-check button (calls `/api/v1/health` only); stateful widget |
| `lib/features/home/home_screen.dart` | Updated roadmap status: "Real API mode available via dart-define" |
| `test/api_client_test.dart` | New: fixture mode tests for getCardDetail/getHealth, http client injection test |
| `test/widget_test.dart` | Added AppConfig defaults tests (fixtureMode=true, apiBaseUrl default) |

## Endpoints used

- `GET /api/v1/cards/{card_key}/detail` — app-ready card detail (v12)
- `GET /api/v1/health` — service status

Both are read-only. No POST/PUT/PATCH/DELETE endpoints. No auth endpoints. No provider/pricing endpoints.

## Mode switching

```
Fixture mode (default):
  flutter run

Real local API mode (opt-in, dev only):
  flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false --dart-define=SAVEROOM_API_BASE_URL=http://127.0.0.1:8765
```

## Safety boundaries

- No API keys or tokens in the app
- No provider calls (JustTCG, TotalTCG, TCGplayer, Cardmarket, eBay, Whatnot, Shopify, LLM)
- No write endpoints
- No billing integration
- No user auth
- No camera/OCR packages
- No SQLite database in the app
- No app-store publishing

## Blocked until later milestones

- v12.3: app user auth/entitlement
- v12.4: scanner/collector backend
- v12.5: paid beta/billing
- Android APK builds (no Android SDK on secondary drive yet)
- Chrome/web builds were validated (no Chrome executable, but `flutter build web --debug` passed previously)

## Verification

```
dart format lib test: passed
flutter pub get: passed
flutter analyze --no-fatal-infos: passed (2 info-level const suggestions)
flutter test: 7/7 passed
flutter build web --debug: passed
```

## Links

- [README.md](../README.md)
- [FIXTURE_MODE.md](../FIXTURE_MODE.md)
- [API_INTEGRATION_PLAN.md](../API_INTEGRATION_PLAN.md)
- [ROADMAP.md](../ROADMAP.md)
- [V0_1_VISUAL_SHELL_REPORT.md](V0_1_VISUAL_SHELL_REPORT.md)