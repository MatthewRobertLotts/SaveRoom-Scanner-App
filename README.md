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
- Real API mode: planned, off by default

### Storage rule

All controllable app source, assets, docs, generated project files, build outputs, and package caches should live on the secondary drive.

Use these cache paths when running Flutter/Dart/Gradle:

```bash
export APP_REPO="/media/matt/Storage/Brain/SaveRoom-Scanner-App"
export API_REPO="/media/matt/Storage/Brain/Pokemon Card Database"
export DEV_CACHE_ROOT="/media/matt/Storage/DevCaches"
export PUB_CACHE="$DEV_CACHE_ROOT/dart-pub-cache"
export GRADLE_USER_HOME="$DEV_CACHE_ROOT/gradle"
export ANDROID_USER_HOME="$DEV_CACHE_ROOT/android-user"
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

### Flutter status

This repo currently contains a safe Flutter source skeleton and docs. `flutter create` was not run because Flutter/Dart were not installed in the current environment during bootstrap.

After Matthew approves/install Flutter on the secondary drive where possible:

```bash
cd "$APP_REPO"
flutter create --org com.saveroom --project-name saveroom_scanner_app .
flutter pub get
flutter analyze
flutter test
```

## Links

- Related: [docs/APP_ARCHITECTURE.md](docs/APP_ARCHITECTURE.md)
- Related: [docs/FIXTURE_MODE.md](docs/FIXTURE_MODE.md)
