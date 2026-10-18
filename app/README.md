# Kirana Mitra app

Flutter client for Kirana Mitra. Android first, web build for the demo link.
Talks to the FastAPI backend described in [`../docs/api-contract.md`](../docs/api-contract.md).

## Run on Chrome (fastest)

```bash
cd app
flutter pub get
flutter run -d chrome
```

By default the app calls `http://localhost:8080`. If `GET /healthz` does not
answer within 3 s at startup, the app switches to the built-in **mock client**
and shows a small "Demo" chip in the chat app bar. The mock keeps stock, udhaar
and undo history in memory, so the whole flow (voice, chat, chips, stock,
udhaar, forecast, reorder, WhatsApp share) is demoable without a backend.

Force the mock even when the backend is up:

```bash
flutter run -d chrome --dart-define=USE_MOCK=true
```

Point at a different backend (for example Cloud Run):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://kirana-mitra-xxxx.a.run.app
```

Voice on the web records `audio/webm` (Opus) because Chrome cannot encode AAC;
the contract accepts it. The backend must send CORS headers for the Chrome
origin (`http://localhost:<port>`), otherwise every call fails and the app
falls back to the mock.

## Run on an Android device with the local backend

1. Start the backend on your Mac (`cd backend && ...`, it listens on 8080).
2. Plug in the phone with USB debugging on, or start an emulator.
3. Emulator: nothing to configure, the app defaults to `http://10.0.2.2:8080`,
   which is the emulator's alias for the host machine.
4. Physical phone on the same Wi-Fi: find your Mac's LAN IP (`ipconfig getifaddr en0`)
   and pass it in:

   ```bash
   flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.1.23:8080
   ```

   Cleartext HTTP is allowed in the manifest for local development.
5. Grant the microphone and camera prompts on first use.

Build a release APK: `flutter build apk --release` (output in
`build/app/outputs/flutter-apk/`).

## Build the web bundle for the demo link

```bash
flutter build web --release --dart-define=API_BASE_URL=https://<cloud-run-url>
```

Serve `build/web/` from any static host (Firebase Hosting, Cloud Storage bucket,
`python3 -m http.server`).

## Layout

| Path | What |
|---|---|
| `lib/api/` | `ApiClient` interface, `DioApiClient` (real), `MockApiClient` (fixtures), Riverpod provider that picks one |
| `lib/models/` | Plain Dart classes with `fromJson`/`toJson` matching the contract |
| `lib/state/` | Shop prefs (shared_preferences), chat controller, data providers, voice recorder |
| `lib/screens/` | Onboarding, Chat, Stock, Udhaar, Forecast |
| `lib/widgets/` | Mic button, message bubble + chips, typing indicator, async list body |
| `lib/l10n/` | `app_en.arb`, `app_hi.arb`; generated `app_localizations*.dart` |
| `lib/theme.dart` | Warm palette, 18 sp body, 48 dp+ tap targets |
| `lib/router.dart` | go_router with a 4-tab stateful shell |

Language: Hindi switches the UI to Devanagari strings; English and Hinglish use
the English UI, and the chosen code (`hi`, `en`, `hi-Latn`) is sent to
`POST /shops` so replies come back in that mix.

After editing an `.arb` file run `flutter gen-l10n` (also runs on `flutter run`).
