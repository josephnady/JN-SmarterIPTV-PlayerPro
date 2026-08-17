import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/app_state.dart';
import '../theme.dart';
import 'tuner_dial.dart';

class PlayerPanel extends StatefulWidget {
  const PlayerPanel({super.key});

  @override
  State<PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  Timer? _epgTimer;

  @override
  void initState() {
    super.initState();
    _epgTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      context.read<AppState>().refreshEpgForActiveChannel();
    });
  }

  @override
  void dispose() {
    _epgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final controller = state.videoController;

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildVideoArea(state, controller),
          ),
        ),
        const TunerDial(),
      ],
    );
  }

  Widget _buildVideoArea(AppState state, VideoPlayerController? controller) {
    if (state.activeChannel == null) {
      return const Center(
        child: Text('Select a channel to tune in', style: TextStyle(color: AppColors.textFaint)),
      );
    }
    if (state.videoLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (state.videoError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.videoError!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
        ),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _Controls(controller: controller)),
      ],
    );
  }
}

class _Controls extends StatefulWidget {
  final VideoPlayerController controller;
  const _Controls({required this.controller});

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, _) => IconButton(
              icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.text),
              onPressed: () => value.isPlaying ? controller.pause() : controller.play(),
            ),
          ),
          SizedBox(
            width: 100,
            child: Slider(
              value: _volume,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.line,
              onChanged: (v) {
                setState(() => _volume = v);
                controller.setVolume(v);
              },
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.isPlaying) ...[
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.live, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('LIVE',
                      style: TextStyle(fontSize: 11, color: AppColors.live, letterSpacing: 1.2, fontFamily: 'monospace')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
