# SaveRoom Scanner App

Tags: #type/project

## Overview

SaveRoom Scanner App is a separate Flutter/mobile/frontend repo for visual scanner and collection UI work. It consumes the released SaveRoom Pokémon Database/API baseline `v12.2.0`; it does not ship the API/database brain inside the app.

## Body

### Baseline

- API repo: `/media/matt/Storage/Brain/Pokemon Card Database`
- App repo: `/media/matt/Storage/Brain/SaveRoom-Scanner-App`
- API baseline: `v12.2.0` on `main` at `4a3d91806999b168c6866c0c4f050ddae8557205`
- Default app mode: fixture mode
- Real local API mode: opt-in via `--dart-define=SAVEROOM_FIXTURE_MODE=false`

### Storage rule

All controllable app source, assets, docs, generated project files, build outputs, and package caches should live on the secondary drive.

| Variable | Path |
|----------|------|
| `ANDROID_SDK_ROOT` | `/media/matt/Storage/DevTools/android-sdk` |
| `ANDROID_HOME` | `$ANDROID_SDK_ROOT` |
| `GRADLE_USER_HOME` | `$DEV_CACHE_ROOT/gradle` |
| `ANDROID_USER_HOME` | `$DEV_CACHE_ROOT/android-user` |
| `PUB_CACHE` | `$DEV_CACHE_ROOT/dart-pub-cache` |

Example:

```bash
export APP_REPO="/media/matt/Storage/Brain/SaveRoom-Scanner-App"
export API_REPO="/media/matt/Storage/Brain/Pokemon Card Database"
export DEV_CACHE_ROOT="/media/matt/Storage/DevCaches"
export DEV_TOOLS_ROOT="/media/matt/Storage/DevTools"
export FLUTTER_SDK="$DEV_TOOLS_ROOT/flutter"
export ANDROID_SDK_ROOT="$DEV_TOOLS_ROOT/android-sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PUB_CACHE="$DEV_CACHE_ROOT/dart-pub-cache"
export GRADLE_USER_HOME="$DEV_CACHE_ROOT/gradle"
export ANDROID_USER_HOME="$DEV_CACHE_ROOT/android-user"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$FLUTTER_SDK/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
```

### Safety boundaries

- No real provider calls.
- No JustTCG/TotalTCG/TCGplayer/Cardmarket/eBay/Whatnot/Shopify/LLM calls.
- No billing yet.
- No login yet.
- No camera/OCR yet.
- No raw API keys for mobile users.
- No API keys, provider credentials, raw provider payloads, private headers, account metadata, marketplace data, `.env` files, or SQLite database files in this repo.
- No app-store publishing.

### Future backend plan

- `v12.3.0`: app user/auth/entitlement foundation.
- `v12.4.0`: scanner/collector backend foundation.
- `v12.5.0`: paid beta/billing integration.
- `v13.0`: only with explicit Matthew approval.

### Flutter / Android build status

Flutter SDK is installed on the secondary drive at `/media/matt/Storage/DevTools/flutter`.
Android SDK is installed on the secondary drive at `/media/matt/Storage/DevTools/android-sdk`.

| Validation | Result |
|-----------|--------|
| `dart format lib test` | ✅ |
| `flutter pub get` | ✅ |
| `flutter analyze --no-fatal-infos` | ✅ (2 infos) |
| `flutter test` | ✅ 7/7 |
| `flutter build web --debug` | ✅ |
| `flutter build apk --debug` | ✅ 140MB debug APK |

## Links

- Related: [docs/APP_ARCHITECTURE.md](docs/APP_ARCHITECTURE.md)
- Related: [docs/FIXTURE_MODE.md](docs/FIXTURE_MODE.md)


## Visual shell status (v0.1)

The v0.1 visual shell is polished and fixture-first:

- Dark Material 3 SaveRoom identity.
- Home, scanner placeholder, mock scan result, card detail, collection, and settings screens improved.
- Reusable widgets for section cards, status pills, fixture badge, and action cards.
- Card detail reads `card_detail_response.json` defensively.
- No real API calls by default.
- No auth, billing, camera/OCR, provider calls, or app-store publishing.

## Real local API read mode (v0.2)

v0.2 adds real local API read mode using v12.2.0 endpoints:

- Fixture mode remains the default.
- Real local API mode is opt-in via `--dart-define=SAVEROOM_FIXTURE_MODE=false`.
- Endpoints used: `GET /api/v1/cards/{card_key}/detail` and `GET /api/v1/health`.
- Read-only: no POST/PUT/PATCH/DELETE endpoints.
- No API keys/tokens in the app.
- No auth, billing, provider, or write endpoints.
- Settings screen includes a user-triggered health-check button.
- Tests: 7/7 passed (fixture mode, AppConfig defaults, http injection).
- Backend not required for tests.

| Validation | Result |
|-----------|--------|
| `dart format lib test` | ✅ |
| `flutter pub get` | ✅ |
| `flutter analyze --no-fatal-infos` | ✅ (2 infos) |
| `flutter test` | ✅ 7/7 |
| `flutter build web --debug` | ✅ |
| `flutter build apk --debug` | ✅ 140MB debug APK at `build/app/outputs/flutter-apk/app-debug.apk` |

See [docs/ANDROID_BUILD_SETUP.md](docs/ANDROID_BUILD_SETUP.md) for SDK paths and commands.