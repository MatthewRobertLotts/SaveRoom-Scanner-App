# API Integration Plan

Tags: #type/project

## Overview

The app targets the released SaveRoom Pokémon Database/API `v12.2.0` baseline. Integration starts in fixture mode, then moves to local real API read mode after the shell is stable.

## Body

### Baseline

- API baseline: `v12.2.0`
- OpenAPI/client generation: planned, not added yet.
- Default mode: fixture mode.
- Real API calls: off by default.

### Likely first endpoints

- `GET /api/v1/cards/{card_key}/detail`
- `POST /api/v1/cards/detail/batch`
- `GET /api/v1/inventory/items`
- `GET /api/v1/sales/summary`

### Not present / future backend work

- `/api/v1/me`
- entitlement checks for app users
- collection records
- scan candidates response shape
- subscription status

### Safety

No API key is committed. No user token is committed. No provider credentials are committed. The app must run without backend access in fixture mode.

## Links

- Related: [APP_ARCHITECTURE.md](APP_ARCHITECTURE.md)
- Related: [FIXTURE_MODE.md](FIXTURE_MODE.md)
