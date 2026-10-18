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
| `lib/state/` | Shop prefs, chat controller, data providers, voice recorder, mic state, local history cache |
| `lib/screens/` | Onboarding, Chat, Stock, Udhaar, Customer history, Forecast |
| `lib/widgets/` | Design-system components from `docs/design/handoff.md`: `KmButton`, `KmChip`, `KmBadge`, `KmRow`, `KhataCard`, `ReplyCard` (Samjha / Pakka nahi / scan), `DemandChart`, mic dock + recording sheet + FAB, `LangChip`, app bar, nav bar, order sheet, hisaab card |
| `lib/theme/` | `tokens.dart` (colours, spacing, radii, sizes), `typography.dart` (type scale), `theme.dart` (Material theme) |
| `lib/util/format.dart` | Indian rupee grouping, dates, times |
| `lib/l10n/` | `app_en.arb` (Hinglish-leaning), `app_hi.arb` (Devanagari); generated `app_localizations*.dart` |
| `lib/router.dart` | go_router with a 4-tab stateful shell |
| `fonts/` | Baloo 2, Noto Sans, Noto Sans Devanagari (variable TTFs, OFL) bundled so the app renders offline |

Language: Hindi switches the UI to Devanagari strings; English and Hinglish use
the English UI, and the chosen code (`hi`, `en`, `hi-Latn`) is sent to
`POST /shops` so replies come back in that mix. The language chip in every app
bar changes it later; the choice is stored locally.

## Design v2

The UI follows `docs/design/handoff.md`. Every colour, size and radius used by a
screen comes from `lib/theme/tokens.dart`; every user-visible string comes from
the ARB files. Known gaps against the handoff:

- Evening hisaab is reachable from the chat overflow menu; the 21:30 local
  notification is not wired (needs a notifications package and permissions).
- Customer history is built from a local cache of the last 50 applied replies
  (`lib/state/history_store.dart`) because the contract has no per-customer
  endpoint yet.
- The logo mark is painted in Dart (`lib/widgets/logo_mark.dart`) rather than
  loaded from an SVG asset.

After editing an `.arb` file run `flutter gen-l10n` (also runs on `flutter run`).
