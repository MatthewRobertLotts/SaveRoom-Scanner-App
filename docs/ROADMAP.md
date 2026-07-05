# Roadmap

Tags: #type/project

## Overview

This roadmap keeps the app small until the API has the next backend foundations.

## Body

- `v0.1 app shell ✅`: fixture UI, navigation, mock scan result.
- `v0.2 real API read mode ✅`: card detail/search integration with local API.
- `v0.3 fixture card selection ✅`: 5 fixture cards, searchable picker, pricing formatting fix.
- `v0.4 auth-aware UI`: login mock, `/me` once v12.3 exists, entitlement display.
- `v0.5 collection UI`: owned-card screens once v12.4 backend exists.
- `v0.6 scanner MVP`: camera/OCR/scan candidate flow.
- `paid beta`: after v12.5 billing/entitlement enforcement.

### v0.3 fixture card selection — completed

- 5 demo fixture cards: Charizard ex, Miraidon ex, Iono, Greninja ex, Giratina V.
- Scanner screen replaced with searchable fixture card picker.
- Card detail reads cardKey from route arguments (no hardcoded Charizard).
- Pricing/evidence section now formatted: £87.90 GBP instead of raw `{amount:87.9,...}`.
- Rarity null display: "Unknown / fixture pending" for missing rarity.
- Scanner empty state: "No fixture cards found".
- All 5 fixture cards verified in tests (47 tests total).
- Backend not required for any tests.

- `v0.5 live API card search ✅`: real API card search from emulator to Zima API via `GET /api/v1/search/cards`. Reuses scanner screen with mode-conditional UI. `SearchResult` helper class. Debounced search (400ms). Zima API must be reachable over LAN.

- `v0.6 image loading / scanner planning`: pending Matthew approval.

No v13 work, billing, login, scanner backend tables, or app-store publishing in current milestone.

## Links

- Related: [../README.md](../README.md)
- Related: [APP_ARCHITECTURE.md](APP_ARCHITECTURE.md)
- Related: [V0_2_REAL_LOCAL_API_MODE_REPORT.md](V0_2_REAL_LOCAL_API_MODE_REPORT.md)