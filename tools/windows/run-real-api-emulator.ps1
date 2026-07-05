# SaveRoom Scanner App — Real API emulator runner (Windows PowerShell)
# ponytail: one-liner wrapped in a repeatable script. Edit the URL below.
# Usage:  .\run-real-api-emulator.ps1
#         or set $env:API_URL first.

$ApiUrl = if ($env:API_URL) { $env:API_URL } else { "http://192.168.178.29:8765" }

Write-Host "Starting SaveRoom Scanner in real API mode..."
Write-Host "API URL: $ApiUrl"
Write-Host ""

cd "$env:USERPROFILE\Documents\GitHub\SaveRoom-Scanner-App"
flutter run --dart-define=SAVEROOM_FIXTURE_MODE=false --dart-define=SAVEROOM_API_BASE_URL=$ApiUrl