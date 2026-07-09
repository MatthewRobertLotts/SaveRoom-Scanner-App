# PC VS Code + Android Emulator Workflow

Tags: #type/reference

## Overview

The SaveRoom Scanner App now uses a two-machine split:

| Machine | Role |
|---------|------|
| Zima board (this Linux machine) | Hermes implementation, backend/API/database work, git commits/pushes |
| Windows PC (Matthew) | VS Code, Android emulator, visual testing, hot reload |
| GitHub | Clean sync point between both machines |

## Normal workflow

1. Hermes works on the Zima-side app repo.
2. Hermes validates, commits, and pushes to GitHub.
3. Matthew pulls on Windows PC.
4. Matthew runs in VS Code + Android emulator.
5. Matthew reports screenshots, videos, or errors back.

## PC commands

```bash
git pull origin main
flutter pub get
flutter devices           # confirm emulator is listed
flutter run               # starts on connected emulator
```

## Avoiding Windows-generated noise

Windows Flutter may modify `pubspec.lock`, `linux/`, `macos/`, `windows/` directories. Do not commit these from the PC.

```bash
git restore pubspec.lock linux macos windows
```

## API note for emulator

`127.0.0.1` inside the Android emulator means the emulator itself, not the Zima board. When testing real API mode, use the Zima LAN IP:

```bash
flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false \
  --dart-define=SAVEROOM_API_BASE_URL=http://192.168.x.x:8765
```

Find the Zima board LAN IP with `hostname -I` or check your router.

## Do not

- Use the Samba/network share as the active Flutter build workspace — copy/clone the repo locally on the Windows PC.
- Commit build outputs, APKs, caches, or generated platform noise from either machine.


## Matthew testing checklist (v0.7.4)

1. Pull latest: `git pull origin main`.
2. Ensure Zima API is running and reachable over LAN.
3. Run real API mode with the Zima LAN IP, not emulator localhost:
   ```bash
   flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false \
     --dart-define=SAVEROOM_API_BASE_URL=http://192.168.178.29:8765
   ```
4. Search `pika`; confirm Pikachu rows appear and thumbnails load where the API has images.
5. Search `pikachu`, `chari`, `vile`, and `cynda`; confirm rows still appear and thumbnails load where images exist.
6. Open several cards; confirm detail images still load.
7. Return home; confirm Recently viewed appears and recent thumbnails load where images exist.
8. Confirm no thumbnail Flutter framework error text, no overflow, no camera/OCR permission prompt, no login/billing/API-key prompt, and no raw map/debug section.

## Matthew testing checklist (v0.6.5)

1. Pull latest: `git pull origin main`.
2. Run real API mode (`tools/windows/run-real-api-emulator.ps1` or the dart-define command above).
3. Open Settings and confirm API health.
4. Search Special Delivery Charizard and confirm image still loads.
5. Search Charizard and open Base/Base2/Base-style Charizard rows; confirm images load if the web UI has them.
6. Search Cyndaquil and open it; confirm image loads if the web UI has one.
7. Search Vileplume and open it; confirm image loads if the web UI has one.
8. Search `pika` and open several normal Pikachu rows; confirm images load where the web UI has them.
9. Search `vilep`; confirm Vileplume appears without weak Weedle noise when strong results exist.
10. Search nonsense; confirm "No cards found".
11. Confirm no bare `/`, no `null/null`, no raw API exception body, no login, no billing, no camera/OCR, no API key prompt, no raw map/debug section.

## Links

- [README.md](../README.md)
- [ANDROID_BUILD_SETUP.md](ANDROID_BUILD_SETUP.md)
- [PHONE_INSTALL.md](PHONE_INSTALL.md)
- [REAL_API_EMULATOR_TESTING.md](REAL_API_EMULATOR_TESTING.md)