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

## Matthew testing checklist (v0.3)

1. Pull latest: `git pull origin main`.
2. Open VS Code.
3. Select Android emulator (not Windows).
4. Press F5.
5. Tap Start Scanner.
6. Search "char" — confirm only Charizard appears.
7. Clear search — all 5 cards visible.
8. Tap each fixture card — confirm detail updates for each.
9. Scroll to Pricing / evidence — confirm formatted £ amounts, no raw `{amount:...}` text.
10. Check rarity shows "Unknown / fixture pending" for Charizard (null rarity).
11. Search "zzz" — confirm empty state "No fixture cards found".
12. Search "sv04" — confirm Miraidon ex shown.
13. Report screenshots/video if anything looks wrong.

## Links

- [README.md](../README.md)
- [ANDROID_BUILD_SETUP.md](ANDROID_BUILD_SETUP.md)
- [PHONE_INSTALL.md](PHONE_INSTALL.md)
- [REAL_API_EMULATOR_TESTING.md](REAL_API_EMULATOR_TESTING.md)