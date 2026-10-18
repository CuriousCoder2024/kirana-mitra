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

## Android

Verified on a OnePlus 7T (Android 11, API 30) on 2026-10-18: onboarding, typed
udhaar entry, hold-to-talk voice note (mic prompt, transcript, Hinglish/Hindi
confirmation), camera shelf scan and Stock refresh, all against the live backend.
Screenshots for slides are in [`docs/screens/android/`](docs/screens/android/).

### Build and install

```bash
cd app
yes | flutter doctor --android-licenses      # once; harmless if already accepted
flutter build apk --release --dart-define API_BASE_URL=http://<mac-lan-ip>:8080
flutter install -d <device-id> --release
```

The APK lands in `build/app/outputs/flutter-apk/app-release.apk` (about 60 MB,
all ABIs; `--split-per-abi` gives ~22 MB per ABI). Release is signed with the
debug key for the hackathon. `minSdk` is 24 (Flutter's default and what
`record`, `image_picker` and `shared_preferences` require); `targetSdk` 36.

Code shrinking (R8) is **off** for release builds in `android/app/build.gradle.kts`:
with it on, R8 strips Kotlin coroutine/stdlib classes that
`shared_preferences_android` reaches through Pigeon suspend functions, every
preferences call fails, and the app never leaves the splash.

The launcher icon comes from `assets/icon/*.svg` via `flutter_launcher_icons`
(config at the bottom of `pubspec.yaml`); regenerate with
`dart run flutter_launcher_icons`. The label is "Kirana Mitra".

### Reach the backend from the phone

* **Emulator**: nothing to do, the default is `http://10.0.2.2:8080`.
* **Phone on the same Wi-Fi**: start the backend bound to all interfaces
  (`uvicorn app.main:app --host 0.0.0.0 --port 8080`; the default `127.0.0.1`
  refuses the phone), find the Mac's IP with `ipconfig getifaddr en0` and pass it
  as `API_BASE_URL`. Cleartext HTTP is allowed in the manifest.
* **Phone over USB** (no Wi-Fi needed): `adb reverse tcp:8080 tcp:8080`, then
  point the app at `http://127.0.0.1:8080` with the runtime override below.

### Runtime server override (no rebuild)

Long-press the **Kirana Mitra** title on the onboarding screen. A "Server" sheet
opens with the base URL (empty = the build default). **Test** calls `/healthz`;
**Save** stores it in `shared_preferences` (key `server_url`) and re-runs the
live-vs-mock check. The saved value wins over `--dart-define API_BASE_URL`.
Clear the field and save to go back to the build default. Code:
`lib/settings/server_settings.dart`.

If the backend is unreachable the app falls back to the mock after the health
check times out; the startup splash shows the error if a startup provider fails.

## iOS

The `ios/` folder is scaffolded (`flutter create --platforms ios --org
com.singapuria`, bundle id `com.singapuria.kiranaMitra`, deployment target
iOS 13.0 in both the Xcode project and the Podfile). `Info.plist` has
`NSMicrophoneUsageDescription`, `NSCameraUsageDescription`,
`NSPhotoLibraryUsageDescription` and `NSAppTransportSecurity` with
`NSAllowsLocalNetworking` so `http://<mac-lan-ip>:8080` works in development.
Launcher icons are generated into `Runner/Assets.xcassets`.

`pod install` has been run (5 pods; `Podfile.lock` is committed, `Pods/` is
not). Nothing on iOS has been built or run yet because this Mac has only the
Command Line Tools. To run it:

1. Install **Xcode** from the App Store (not just the Command Line Tools), open
   it once and accept the licence.
2. Point the tools at it and finish first launch:

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. Refresh the pods (CocoaPods 1.16 on Ruby 4 needs a UTF-8 locale, otherwise
   it dies with "Unicode Normalization not appropriate for ASCII-8BIT"):

   ```bash
   cd app/ios && LANG=en_US.UTF-8 pod install && cd ..
   ```

4. Run on a device or the simulator:

   ```bash
   flutter devices
   flutter run -d <iphone> --dart-define API_BASE_URL=http://<mac-lan-ip>:8080
   # or
   flutter run -d "iPhone 17" --dart-define API_BASE_URL=http://localhost:8080
   ```

   For a real iPhone, open `ios/Runner.xcworkspace` once in Xcode, pick your
   free personal team under Signing & Capabilities, and trust the developer
   profile on the phone (Settings > General > VPN & Device Management).
   The simulator has no camera; the shelf-scan button opens the photo library
   there. The runtime server override (long-press the title) works the same as
   on Android.

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
