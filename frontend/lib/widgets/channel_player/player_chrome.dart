import 'package:flutter/material.dart';

import '../../theme.dart';

/// Shared video-controls chrome (play/pause, volume, live badge) laid over
/// whatever video surface the platform-specific player provides. Keeps the
/// UI identical between the native (video_player) and web (HTML5 + hls.js)
/// implementations.
class PlayerChrome extends StatelessWidget {
  final Widget videoSurface;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const PlayerChrome({
    super.key,
    required this.videoSurface,
    required this.isPlaying,
    required this.onPlayPause,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: videoSurface),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bg.withOpacity(0.72),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.text),
                  onPressed: onPlayPause,
                ),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: volume,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.line,
                    onChanged: onVolumeChanged,
                  ),
                ),
                const Spacer(),
                if (isPlaying) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: AppColors.live, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('LIVE',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.live, letterSpacing: 1.2, fontFamily: 'monospace')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
