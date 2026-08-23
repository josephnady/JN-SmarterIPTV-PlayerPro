import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:video_player/video_player.dart';

import '../../theme.dart';
import 'player_chrome.dart';

class ChannelPlayer extends StatefulWidget {
  final String? streamUrl;
  @Preview(name: "ChannelPlayer")
  const ChannelPlayer({super.key, required this.streamUrl});

  @override
  State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;

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
      await controller.initialize();
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
          onVolumeChanged: (v) => controller.setVolume(v),
        );
      },
    );
  }
}
