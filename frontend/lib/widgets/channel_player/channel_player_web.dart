import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Plays a channel's HLS stream in the browser using hls.js.
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
  late final JSFunction _onFullscreenChangeJs;
  JSFunction? _onLoadedDataJs;
  _Hls? _hls;

  bool _loading = false;
  bool _isPlaying = false;
  double _volume = 1.0;
  double _lastVolume = 0.7; // State to remember the last volume level
  String? _error;

  @override
  void initState() {
    super.initState();
    _instanceCounter++;
    _viewType = 'jn-iptv-video-$_instanceCounter';

    _video = web.HTMLVideoElement()
      ..autoplay = true
      ..muted = false
      ..controls = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain';

    _onPlayJs = ((web.Event _) {
      if (mounted) setState(() => _isPlaying = true);
    }).toJS;
    _onPauseJs = ((web.Event _) {
      if (mounted) setState(() => _isPlaying = false);
    }).toJS;
    _video.addEventListener('play', _onPlayJs);
    _video.addEventListener('pause', _onPauseJs);

    // Sync state when browser enters/exits fullscreen (e.g. Esc key)
    _onFullscreenChangeJs = ((web.Event _) {
      if (mounted) setState(() {});
    }).toJS;
    web.document.addEventListener('fullscreenchange', _onFullscreenChangeJs);

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
      final canPlayNative =
          _video.canPlayType('application/vnd.apple.mpegurl').isNotEmpty;

      if (hlsAvailable) {
        final hls = _Hls({'maxBufferLength': 100}.jsify());
        _hls = hls;
        hls.loadSource(url);
        hls.attachMedia(_video);
      } else if (canPlayNative) {
        _video.src = url;
      } else {
        setState(() {
          _loading = false;
          _error =
              "This browser can't play HLS streams, and hls.js wasn't found.\n"
              'Make sure the hls.js <script> tag from the README is in web/index.html.';
        });
        return;
      }

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

  void _onVolumeToggle() {
    setState(() {
      final currentVolume = _video.volume;
      if (currentVolume > 0) {
        _lastVolume = currentVolume;
        _video.volume = 0;
        _volume = 0;
      } else {
        _video.volume = _lastVolume;
        _volume = _lastVolume;
      }
      _video.muted = _volume == 0;
    });
  }

  void _seekRelative(Duration offset) {
    _video.currentTime += offset.inSeconds.toDouble();
  }

  void _toggleFullScreen() {
    final doc = web.document;
    if (doc.fullscreenElement == null) {
      // Enter Fullscreen
      doc.documentElement?.requestFullscreen();
      // for web browsers
      _video.requestFullscreen();

      // Hint for mobile browsers
      // SystemChrome.setPreferredOrientations([
      //   DeviceOrientation.landscapeLeft,
      //   DeviceOrientation.landscapeRight,
      // ]);
    } else {
      // Exit Fullscreen
      doc.exitFullscreen();

      // SystemChrome.setPreferredOrientations([
      //   DeviceOrientation.portraitUp,
      // ]);
    }
    doc.documentElement?.requestFullscreen();

  }

  void _teardown() {
    if (_hls != null) {
      try {
        _hls!.destroy();
      } catch (_) {}
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
    web.document.removeEventListener('fullscreenchange', _onFullscreenChangeJs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streamUrl == null) {
      return const Center(
        child: Text('Select a channel to tune in',
            style: TextStyle(color: AppColors.textFaint)),
      );
    }
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!,
              style: const TextStyle(color: AppColors.danger),
              textAlign: TextAlign.center),
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
          _video.muted = false;
          unawaited(_video.play().toDart.catchError((_) => null));
        }
      },
      volume: _volume,
      onVolumeChanged: (v) {
        setState(() {
          _volume = v;
          if (v > 0) _lastVolume = v;
        });
        _video
          ..muted = false
          ..volume = v;
      },
      onVolumeToggle: _onVolumeToggle,
      onSeekBackward: () => _seekRelative(const Duration(seconds: -10)),
      onSeekForward: () => _seekRelative(const Duration(seconds: 10)),
      onToggleFullScreen: _toggleFullScreen,
      isFullScreen: web.document.fullscreenElement != null,
    );
  }
}
