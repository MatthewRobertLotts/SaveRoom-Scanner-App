# Roadmap

Tags: #type/project

## Overview

This roadmap keeps the app small until the API has the next backend foundations.

## Body

- `v0.1 app shell ✅`: fixture UI, navigation, mock scan result.
- `v0.2 real API read mode ✅`: card detail/search integration with local API.
- `v0.3 auth-aware UI`: login mock, `/me` once v12.3 exists, entitlement display.
- `v0.4 collection UI`: owned-card screens once v12.4 backend exists.
- `v0.5 scanner MVP`: camera/OCR/scan candidate flow.
- `paid beta`: after v12.5 billing/entitlement enforcement.

### v0.2 completed

- http package added.
- Real API client methods: getCardDetail, getHealth.
- Fixture mode remains default.
- Opt-in via `--dart-define=SAVEROOM_FIXTURE_MODE=false`.
- Settings screen: mode display + health-check button.
- Card detail screen: uses API client, graceful fallback.
- Tests: 7/7 passed (fixture mode, AppConfig defaults, http injection).
- Backend not required for tests.
- No auth/tokens/billing/camera/OCR.

No v13 work, billing, login, scanner backend tables, or app-store publishing in current milestone.

## Links

- Related: [../README.md](../README.md)
- Related: [APP_ARCHITECTURE.md](APP_ARCHITECTURE.md)
- Related: [V0_2_REAL_LOCAL_API_MODE_REPORT.md](V0_2_REAL_LOCAL_API_MODE_REPORT.md)