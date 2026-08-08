<div align="center">
  <h1>SaveRoom Scanner App</h1>
  <p><strong>Flutter frontend for Pokémon TCG card lookup, pricing, collection, and seller workflows.</strong></p>
</div>

<p align="center">
  <a href="https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App/actions/workflows/flutter-ci.yml"><img src="https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App/actions/workflows/flutter-ci.yml/badge.svg" alt="Flutter CI"></a>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/API-SaveRoom%20v12.2.0-22498e" alt="API v12.2.0">
</p>

## What this is

SaveRoom Scanner App is the mobile/client frontend for the [SaveRoom Pokémon Card Database API](https://github.com/MatthewRobertLotts/SaveRoom-Pokemon-Database-API). It is built fixture-first so UI work can continue without a live backend.

## Current status

| Area | Status |
|---|---|
| Card search and autocomplete | Done |
| Card detail with images | Done |
| Market price display | Done |
| Fixture mode for app QA | Done |
| Collection workflows | In progress |
| Camera scanner | Planned |
| Inventory/seller workflows | Planned |

## Why it matters

- Demonstrates Flutter app structure, API boundaries, state/data modelling, and mobile UI delivery.
- Consumes a real backend contract instead of embedding the database in the app.
- Supports reliable demo/testing through local fixtures.

## Quick start

```bash
git clone https://github.com/MatthewRobertLotts/SaveRoom-Scanner-App.git
cd SaveRoom-Scanner-App
flutter pub get
flutter test
flutter run
```

Run against a local API:

```bash
flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false
```

## Architecture

```text
SaveRoom Scanner App
├── Screens: search, detail, scanner, collection
├── Widgets: image panels, search, pricing, cards
├── Services: API client, fixture provider
└── Models: card, set, pricing, inventory
        │
        ▼
SaveRoom Pokémon DB API v12.2.0
```

## Related

| Project | Purpose |
|---|---|
| This repo | Flutter scanner and collection frontend |
| [SaveRoom Pokémon Card Database API](https://github.com/MatthewRobertLotts/SaveRoom-Pokemon-Database-API) | Backend API and data platform |

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
