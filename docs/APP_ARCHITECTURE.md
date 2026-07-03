# App Architecture

Tags: #type/project

## Overview

SaveRoom Scanner App is the Flutter/mobile visual frontend for scanner and collection workflows. The SaveRoom Pokémon Database/API remains the backend brain and is not shipped in the app.

## Body

### App responsibilities

- Visual UI and navigation.
- Fixture-mode mock screens.
- Future camera/scanner flow.
- Future local UI state/cache.
- Future generated API client integration.

### API responsibilities

- Canonical Pokémon database.
- Pricing intelligence.
- Image/provenance layer.
- Inventory/listing/sales workflow.
- Auth/scopes/quotas foundation.
- OpenAPI contracts and fixtures.

### Boundary

The SQLite database, provider credentials, raw provider payloads, marketplace account metadata, and pricing provider logic stay out of the app. Mobile users should receive app login/session tokens after v12.3 backend work, not raw developer API keys.

### Fixture mode vs real API mode

Fixture mode is the default and must run without backend access. Real API read mode will use `SAVEROOM_API_BASE_URL` and the v12.2.0 app-safe endpoints later.

### Secondary-drive storage rule

All controllable app source, assets, generated files, build outputs, docs, and package caches should stay under `/media/matt/Storage`.

## Links

- Related: [../README.md](../README.md)
- Related: [API_INTEGRATION_PLAN.md](API_INTEGRATION_PLAN.md)
