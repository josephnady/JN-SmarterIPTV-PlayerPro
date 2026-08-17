# JN Smarter IPTV Player Pro — Flutter frontend

A cross-platform Flutter client (Android, iOS, desktop, web) for the
[Spring Boot backend](../backend) — same dark "tuner console" look as the Electron desktop
app, driven entirely over HTTP instead of Electron IPC.

## 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.19+ (Dart 3.3+)
- The [backend](../backend) running and reachable (`mvn spring-boot:run`, default `http://localhost:8787`)

## 2. Generate the native platform folders

This project ships only `lib/` and `pubspec.yaml` — the `android/`, `ios/`, `linux/`,
`macos/`, `windows/`, and `web/` folders are the boilerplate Flutter normally generates for
you, so create them once locally:

```bash
cd frontend_flutter
flutter create --project-name jn_smarter_iptv_player_pro .
flutter pub get
```

`flutter create .` on a folder that already has `lib/` and `pubspec.yaml` fills in the missing
platform folders without touching your existing source — safe to run.

## 3. Allow local HTTP traffic

The backend runs on plain `http://`, and both Android and iOS block cleartext (non-HTTPS)
network calls by default. After step 2, apply these one-time tweaks:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
  <uses-permission android:name="android.permission.INTERNET" />
  <application
      android:usesCleartextTraffic="true"
      ... >
```

**iOS** — `ios/Runner/Info.plist`, inside the top-level `<dict>`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Desktop (Windows/macOS/Linux) and web builds don't need either of these.

## 4. Run it

```bash
flutter run
```

On first launch the app tries `http://localhost:8787`. That resolves correctly on
**desktop** and **web** if the backend runs on the same machine. On a **mobile
emulator/device** it won't — use the tune icon → Settings and point it at:

- Android emulator: `http://10.0.2.2:8787` (special alias for the host machine)
- Real phone/tablet: your computer's LAN IP, e.g. `http://192.168.1.10:8787`

The URL is saved locally (`shared_preferences`) so you only set it once per device.

## 5. What's implemented

- Add playlists via **Xtream login**, **M3U/M3U8 URL**, or a **local file** (matches the
  backend's three creation endpoints exactly)
- Playlist rail, channel sidebar with search/group filter/All-Favorites tabs
- Video playback (`video_player` — HLS via ExoPlayer on Android, AVPlayer on iOS) with
  play/pause, volume, and a live indicator
- Tuner dial showing channel number, name, and now/next EPG, polled every 30s
- Full programme guide panel (end drawer)
- Settings dialog: backend URL, resume-last-channel toggle, per-playlist refresh/remove
- Responsive layout — three-pane view ≥900px wide, drawer-based layout below that

## 6. Project structure

```
frontend_flutter/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── theme.dart              # color tokens + ThemeData, matches the desktop app
    ├── models/                 # Playlist, Channel, EpgResponse, AppSettingsModel
    ├── services/
    │   ├── api_client.dart     # one method per backend endpoint
    │   └── app_state.dart      # ChangeNotifier: playlists, channels, filters, playback
    ├── screens/home_screen.dart
    └── widgets/                # playlist_rail, channel_sidebar, channel_tile,
                                 # player_panel, tuner_dial, epg_panel,
                                 # add_playlist_sheet, settings_sheet
```

## Notes

- No native HLS proxying/DRM handling — playback quality depends entirely on what
  `video_player` and the stream itself support, same caveat as the desktop app.
- This talks to the backend over plain HTTP with no auth, matching the backend's
  single-user, local-only design — don't point it at a backend exposed to the open internet.
