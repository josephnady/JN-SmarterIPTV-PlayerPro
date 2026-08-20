import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../theme.dart';
import 'player_chrome.dart';

/// Typed interop binding for the global `Hls` class from hls.js.
/// See: https://github.com/video-dev/hls.js
@JS('Hls')
extension type _Hls._(JSObject _) implements JSObject {
external factory _Hls([JSAny? config]);
external static bool isSupported();
external void loadSource(String url);
external void attachMedia(web.HTMLVideoElement media);
external void destroy();
}

/// Plays a channel's HLS stream in the browser using hls.js, since Chrome/
/// Firefox/Edge don't support `.m3u8` natively in a plain `<video>` tag (only
/// Safari does). Requires `hls.js` to be loaded as a `<script>` in
/// `web/index.html` — see the frontend README for the exact tag to add.
///
/// Built on `package:web` + `dart:js_interop` (the current, non-deprecated
/// interop stack) rather than the legacy `dart:html`/`dart:js_util`.
///
/// Starts muted: `attachMedia`/`loadSource` are asynchronous, so nothing is
/// actually attached to the element yet at the point playback would
/// otherwise be requested — calling `play()` there throws `NotSupportedError:
/// no supported sources`. Autoplay is left to the browser (which requires
/// `muted` to fire reliably); a `loadeddata` listener is a safety net for
/// browsers that don't honor the `autoplay` attribute alone. The user's own
/// play button and volume slider both unmute explicitly, since those are
/// real user gestures browsers are happy to allow unmuted playback for.
class ChannelPlayer extends StatefulWidget {
final String? streamUrl;
const ChannelPlayer({super.key, required this.streamUrl});

@override
State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
static int _instanceCounter = 0;

late final String _viewType;
late final web.HTMLVideoElement _video;
late final JSFunction _onPlayJs;
late final JSFunction _onPauseJs;
JSFunction? _onLoadedDataJs;
_Hls? _hls;

bool _loading = false;
bool _isPlaying = false;
double _volume = 1.0;
String? _error;

@override
void initState() {
super.initState();
_instanceCounter++;
_viewType = 'jn-iptv-video-$_instanceCounter';

_video = web.HTMLVideoElement()
..autoplay = true
..muted = true
..controls = false
..style.width = '100%'
..style.height = '100%'
..style.objectFit = 'contain'
..setAttribute('playsinline', 'true');

_onPlayJs = ((web.Event _) {
if (mounted) setState(() => _isPlaying = true);
}).toJS;
_onPauseJs = ((web.Event _) {
if (mounted) setState(() => _isPlaying = false);
}).toJS;
_video.addEventListener('play', _onPlayJs);
_video.addEventListener('pause', _onPauseJs);

ui_web.platformViewRegistry.registerViewFactory(
_viewType,
(int viewId, {Object? params}) => _video,
);

_load(widget.streamUrl);
}

@override
void didUpdateWidget(covariant ChannelPlayer oldWidget) {
super.didUpdateWidget(oldWidget);
if (oldWidget.streamUrl != widget.streamUrl) {
_load(widget.streamUrl);
}
}

Future<void> _load(String? url) async {
_teardown();
setState(() {
_error = null;
_loading = url != null;
_isPlaying = false;
});
if (url == null) return;

try {
final hlsAvailable = globalContext.has('Hls') && _Hls.isSupported();
final canPlayNative = _video.canPlayType('application/vnd.apple.mpegurl').isNotEmpty;

if (hlsAvailable) {
final hls = _Hls({'maxBufferLength': 100}.jsify());
_hls = hls;
hls.loadSource(url);
hls.attachMedia(_video);
} else if (canPlayNative) {
// Safari (and any browser with native HLS support) doesn't need hls.js.
_video.src = url;
} else {
setState(() {
_loading = false;
_error = "This browser can't play HLS streams, and hls.js wasn't found.\n"
'Make sure the hls.js <script> tag from the README is in web/index.html.';
});
return;
}

// Safety net: `autoplay` + `muted` should start playback on their own
// once hls.js/the browser actually has data buffered, but not every
// browser honors the attribute reliably in every case. This only ever
// nudges a still-paused video — never calls play() before there's
// something to play.
if (_onLoadedDataJs != null) {
_video.removeEventListener('loadeddata', _onLoadedDataJs!);
}
_onLoadedDataJs = (() {
if (_video.paused) {
unawaited(_video.play().toDart.catchError((_) => null));
}
}).toJS;
_video.addEventListener('loadeddata', _onLoadedDataJs!);

if (!mounted) return;
setState(() => _loading = false);
} catch (e) {
if (!mounted) return;
setState(() {
_loading = false;
_error = 'Playback error: $e';
});
}
}

void _teardown() {
if (_hls != null) {
try {
_hls!.destroy();
} catch (_) {
// best-effort cleanup
}
_hls = null;
}
if (_onLoadedDataJs != null) {
_video.removeEventListener('loadeddata', _onLoadedDataJs!);
_onLoadedDataJs = null;
}
_video.pause();
_video.removeAttribute('src');
}

@override
void dispose() {
_teardown();
_video.removeEventListener('play', _onPlayJs);
_video.removeEventListener('pause', _onPauseJs);
super.dispose();
}

@override
Widget build(BuildContext context) {
if (widget.streamUrl == null) {
return const Center(
child: Text('Select a channel to tune in', style: TextStyle(color: AppColors.textFaint)),
);
}
if (_loading) {
return const Center(child: CircularProgressIndicator(color: AppColors.accent));
}
if (_error != null) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Text(_error!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
),
);
}

return PlayerChrome(
videoSurface: HtmlElementView(viewType: _viewType),
isPlaying: _isPlaying,
onPlayPause: () {
if (_isPlaying) {
_video.pause();
} else {
// A direct tap is a real user gesture, so it's safe to unmute here.
_video.muted = false;
unawaited(_video.play().toDart.catchError((_) => null));
}
},
volume: _volume,
onVolumeChanged: (v) {
setState(() => _volume = v);
_video
..muted = false
..volume = v;
},
);
}
}
