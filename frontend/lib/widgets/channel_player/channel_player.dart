/// `ChannelPlayer` is the single widget the rest of the app uses to play a
/// channel's stream. Which implementation actually gets compiled in depends
/// on the target:
///
/// - Native (Android/iOS/desktop, has `dart:io`) → [video_player]-backed
///   player. HLS works out of the box via ExoPlayer/AVPlayer.
/// - Web (has `dart:js_interop`) → an HTML5 `<video>` element driven by
///   hls.js via `package:web`, since browsers other than Safari can't play
///   `.m3u8` natively and `video_player` doesn't polyfill that on web.
library channel_player;

export 'channel_player_stub.dart'
    if (dart.library.io) 'channel_player_io.dart'
    if (dart.library.js_interop) 'channel_player_web.dart';
