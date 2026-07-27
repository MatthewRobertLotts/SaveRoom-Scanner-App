# Real API Emulator Testing

Tags: #type/reference

## Purpose

Test read-only real API mode from the Windows Android emulator to the Zima-hosted SaveRoom API over LAN.

## Prerequisites

- Zima API must be reachable over LAN (bind to `0.0.0.0` or the Zima LAN IP).
- Android emulator running on Windows PC.
- App pulled on Windows PC (`git pull origin main`).

## Important

`127.0.0.1` inside the Android emulator means **the emulator itself**, not the Zima board. Always use the Zima LAN IP.

## Find the Zima LAN IP

On the Zima board:

```bash
hostname -I
```

Example: `192.168.178.29`

## Run

The app now defaults to the Zima LAN API in normal VS Code Play mode:

```text
http://192.168.178.29:8765
```

Matthew's normal flow is GitHub Desktop Pull → VS Code Play with the Android emulator selected. Manual `flutter run --dart-define` commands are only needed if testing a different API host or fixture mode.

## What to test

1. Open Settings.
2. Press "Check API health" — confirm API responds.
3. Go to scanner/search screen — confirm title says "Search live API cards".
4. Type at least 3 characters — confirm results appear after debounce.
5. Tap a result — confirm Card detail opens in Live API mode.
6. Search Special Delivery Charizard — confirm its image still loads.
7. Search/open Base Set, Base Set 2, Cyndaquil, Vileplume, and normal Pikachu rows — confirm images load when the API web UI has images.
8. Search `vilep` — confirm Vileplume appears without weak Weedle noise when strong results exist.
9. Try nonsense search — confirm empty state.
10. Try an unreachable IP (stop the Zima API) — confirm friendly error, not crash.
11. Switch back to fixture mode (`flutter run` with no dart-define) — confirm fixture picker still works.


## v0.7.4 thumbnail route notes

Search-result and Recently viewed thumbnails use the deterministic API image content route first:

```text
{SAVEROOM_API_BASE_URL}/api/v1/images/card/{Uri.encodeComponent(cardKey)}/content?size=small
```

For Android emulator testing, `SAVEROOM_API_BASE_URL` must be the Zima LAN URL (for example `http://192.168.178.29:8765`). If the app is run with `127.0.0.1`, thumbnail requests also target emulator localhost and will not reach the Zima API.

v0.7.3 fixed the thumbnail crash/error text. v0.7.4 fixes thumbnail parity by deriving a known API image route from each search result card key before trying existing metadata candidates. Camera/OCR remains out of scope.

## v0.6.5 image fallback notes

The API detail endpoint can return bare TCGdex asset URLs such as `https://assets.tcgdex.net/en/base/base4/4`. Those URLs return HTML at the bare path; usable image bytes are at `/high.png` or `/low.png`. The API web UI also checks `GET /api/v1/images/cards/{card_key}` for local/served image metadata. Flutter now follows the same broad chain: API image metadata, local served routes, direct HTTPS URLs, and TCGdex high/low fallbacks. Local filesystem paths are never passed to `Image.network`.

## Links

- [PC_EMULATOR_WORKFLOW.md](PC_EMULATOR_WORKFLOW.md)
- [PHONE_INSTALL.md](PHONE_INSTALL.md)
- [ANDROID_BUILD_SETUP.md](ANDROID_BUILD_SETUP.md)