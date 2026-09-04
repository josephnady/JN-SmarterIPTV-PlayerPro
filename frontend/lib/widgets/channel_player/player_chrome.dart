import 'package:flutter/material.dart';
import '../../theme.dart';

class PlayerChrome extends StatelessWidget {
  final Widget videoSurface;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onVolumeToggle;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onToggleFullScreen;
  final bool isFullScreen;

  const PlayerChrome({
    super.key,
    required this.videoSurface,
    required this.isPlaying,
    required this.onPlayPause,
    required this.volume,
    required this.onVolumeChanged,
    required this.onVolumeToggle,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onToggleFullScreen,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: videoSurface),

        // Tap-to-seek/Play overlay (Modern feature)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: onSeekBackward,
                child: Container(),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: onPlayPause,
                child: Container(),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: onSeekForward,
                child: Container(),
              ),
            ),
          ],
        ),

        // Bottom Control Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bg.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                // Seek Backward Button
                IconButton(
                  icon: const Icon(Icons.replay_10, color: AppColors.text),
                  onPressed: onSeekBackward,
                ),
                // Play/Pause
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.text),
                  onPressed: onPlayPause,
                ),
                // Seek Forward Button
                IconButton(
                  icon: const Icon(Icons.forward_10, color: AppColors.text),
                  onPressed: onSeekForward,
                ),
                // Volume Controls
                IconButton(
                  icon: Icon(volume == 0 ? Icons.volume_off : Icons.volume_up, color: AppColors.text),
                  onPressed: onVolumeToggle,
                ),
                SizedBox(
                  width: 60,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: volume,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.line,
                      onChanged: onVolumeChanged,
                    ),
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
                          fontSize: 11,
                          color: AppColors.live,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                  // const SizedBox(width: 12),
                ],
                // Full Screen Toggle
                IconButton(
                  icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: AppColors.text),
                  onPressed: onToggleFullScreen,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
