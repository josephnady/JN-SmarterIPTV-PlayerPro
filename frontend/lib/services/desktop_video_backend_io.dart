import 'dart:io' show Platform;

import 'package:fvp/fvp.dart' as fvp;

void registerDesktopVideoBackend() {
  // Android, iOS, and macOS already have official video_player backends —
  // only patch in fvp where one doesn't exist.
  if (Platform.isWindows || Platform.isLinux) {
    fvp.registerWith(options: {
      'platforms': ['windows', 'linux'],
    });
  }
}