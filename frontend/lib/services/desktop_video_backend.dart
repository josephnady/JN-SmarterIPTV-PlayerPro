/// `registerDesktopVideoBackend()` patches in a working `video_player`
/// backend on platforms the official plugin doesn't support (Windows,
/// Linux) via the `fvp` package. It's a no-op everywhere else — Android,
/// iOS, macOS, and web already have official implementations.
///
/// This has to be a conditional export, not a plain import in main.dart:
/// `fvp` depends on `dart:ffi`, which doesn't exist on web. Gating on
/// `dart.library.io` keeps the whole `fvp` dependency tree out of the web
/// compilation unit.
library desktop_video_backend;

export 'desktop_video_backend_stub.dart' if (dart.library.io) 'desktop_video_backend_io.dart';