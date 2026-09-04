import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../theme.dart';
import 'player_chrome.dart';

class ChannelPlayer extends StatefulWidget {
  final String? streamUrl;
  const ChannelPlayer({super.key, required this.streamUrl});

  @override
  State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;
  
  // Logic: Store the volume level so we can restore it after unmuting
  double _lastVolume = 0.7; 

  @override
  void initState() {
    super.initState();
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
    final old = _controller;
    _controller = null;
    setState(() { 
      _error = null; 
      _loading = url != null; 
    });

    if (old != null) { 
      await old.pause(); 
      await old.dispose(); 
    }
    if (url == null) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize().then((_){setState(() {});});
      await controller.setLooping(false);
      await controller.play();
      if (!mounted) { 
        await controller.dispose(); 
        return; 
      }
      setState(() { 
        _controller = controller; 
        _loading = false; 
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { 
        _error = 'Playback error: $e'; 
        _loading = false; 
      });
    }
  }

  void _onVolumeToggle() {
    if (_controller == null) return;
    final currentVolume = _controller!.value.volume;

    if (currentVolume > 0) {
      // Muting: Save current volume first
      _lastVolume = currentVolume;
      _controller!.setVolume(0);
    } else {
      // Unmuting: Restore to the last known volume
      _controller!.setVolume(_lastVolume);
    }
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + offset;
    _controller!.seekTo(newPosition);
  }

  void _toggleFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return PlayerChrome(
          videoSurface: Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          isPlaying: value.isPlaying,
          onPlayPause: () => value.isPlaying ? controller.pause() : controller.play(),
          volume: value.volume,
          onVolumeChanged: (v) {
            controller.setVolume(v);
            if (v > 0) _lastVolume = v; // Update restore point if user slides
          },
          onVolumeToggle: _onVolumeToggle,
          onSeekBackward: () => _seekRelative(const Duration(seconds: -10)),
          onSeekForward: () => _seekRelative(const Duration(seconds: 10)),
          onToggleFullScreen: _toggleFullScreen,
          isFullScreen: MediaQuery.of(context).orientation == Orientation.landscape,
        );
      },
    );
  }
}
