# API Integration Plan

Tags: #type/project

## Overview

The app targets the released SaveRoom Pokémon Database/API `v12.2.0` baseline. Integration starts in fixture mode, then moves to local real API read mode.

## Body

### Baseline

- API baseline: `v12.2.0`
- OpenAPI/client generation: planned, not added yet.
- Default mode: fixture mode (local JSON).
- Real API mode: opt-in via `--dart-define=SAVEROOM_FIXTURE_MODE=false`.

### v0.2 endpoints

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/api/v1/health` | API health check | None (dev API) |
| GET | `/api/v1/cards/{card_key}/detail` | App-ready card detail | None (dev API) |

Read-only only. No POST/PUT/PATCH/DELETE.

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
- Related: [V0_2_REAL_LOCAL_API_MODE_REPORT.md](V0_2_REAL_LOCAL_API_MODE_REPORT.md)