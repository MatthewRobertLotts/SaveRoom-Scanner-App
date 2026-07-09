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
| `flutter analyze --no-fatal-infos` | ✅ (10 info-only suggestions) |
| `flutter test` | ✅ 80/80 |
| `flutter build web --debug` | ✅ |
| `flutter build apk --debug` | ✅ debug APK |


### v0.7.4 thumbnail image parity fix

- v0.7.3 removed the Flutter framework error text from search thumbnails and restored accepted partial-search behaviour, but Matthew confirmed search-result thumbnails still showed placeholders only.
- v0.7.4 prepends a deterministic API image route for every search/recent row with a `cardKey`:
  `GET /api/v1/images/card/{Uri.encodeComponent(cardKey)}/content?size=small`.
- The route uses `AppConfig.apiBaseUrl`, so Windows/Android real API mode uses the Zima LAN host such as `http://192.168.178.29:8765`, not hardcoded `127.0.0.1`.
- Existing local/signed/direct/TCGdex image candidates are preserved after the deterministic API route.
- `CardThumbnail` keeps fixed-size list layout, safely advances candidates after the frame on image failure, and falls back to a clean placeholder without Flutter error text.
- Detail image behaviour remains unchanged; `CardImagePanel` still owns the full detail-view retry path.
- No camera/OCR, auth, billing, provider calls, inventory writes, or API/database copies were added.

### v0.6.7 search breadth + loading UX

- Current app milestone: v0.7 on `main`.
- Partial search diagnostics showed API baseline `v12.2.0` primary search is broad for `pika`/`pikachu`, `charizard`, `vileplume`, and `cyndaquil`, but returns 0 for partial `chari`, `vile`, `vilep`, `cynda`, and `cyndaqui`; autocomplete returned 0 for tested terms; fuzzy is useful for those prefixes but noisy.
- Live search now uses prefix mode for 3–5 character queries: primary + autocomplete together, fuzzy only when the strong merged count is thin, with a final 50-result cap.
- Ranking preserves breadth by distinct card key, not name, so many Pikachu/Charizard/Vileplume/Cyndaquil rows survive while weak fuzzy noise is still filtered.
- Search UX keeps previous results visible during newer requests, shows compact “Updating results…”, and distinguishes API connection failures/timeouts from a successful empty “No cards found”.
- Image panels keep v0.6.6 candidate ordering and now show loading/fallback behaviour before `Image pending`.
- Detail fallback behaviour from v0.6.6 remains preserved.

### v0.6.5 image parity + search quality

- Current app consumes API baseline `v12.2.0`; no API repo changes required.
- Matthew-confirmed v0.6.4 behavior preserved: live API mode connects, prefix searches work, bare `/` subtitles are fixed, Special Delivery Charizard image loads, and live detail renders.
- Image root cause: older/normal cards often expose bare TCGdex asset URLs such as `https://assets.tcgdex.net/en/base/base4/4`, which return HTML at the bare path. Special Delivery-style cards expose direct `.png` URLs, so they worked while Base/Cyndaquil/Vileplume-style cards showed `Image pending`.
- Flutter now enriches detail responses with `GET /api/v1/images/cards/{card_key}` metadata and builds a candidate chain: served relative image routes, direct HTTPS URLs, TCGdex `/high.png`, TCGdex `/low.png`, then fallback.
- Local filesystem paths are ignored for mobile; `localhost`/`127.0.0.1` image URLs are rewritten to the configured API host.
- `CardImagePanel` now attempts image candidates in order and only shows `Image pending` after candidates are exhausted.
- Search ranking is deterministic and source-aware: exact/prefix/contains English results outrank fallback rows; weak fuzzy/autocomplete noise is filtered when strong matches exist; fuzzy-only nonsense rows are suppressed.

## Links

- Related: [docs/APP_ARCHITECTURE.md](docs/APP_ARCHITECTURE.md)
- Related: [docs/PC_EMULATOR_WORKFLOW.md](docs/PC_EMULATOR_WORKFLOW.md)


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