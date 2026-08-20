import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';

class TunerDial extends StatelessWidget {
  const TunerDial({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final channel = state.activeChannel;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  channel != null ? '${channel.channelNumber}' : '--',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
                const Text('CH', style: TextStyle(fontSize: 11, color: AppColors.textFaint, letterSpacing: 1.2)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.line, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  channel?.name ?? 'No channel selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  _epgLine(state),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textFaint, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          if (channel != null)
            IconButton(
              tooltip: 'Toggle favorite',
              icon: Icon(
                channel.favorite ? Icons.star : Icons.star_border,
                color: channel.favorite ? AppColors.accent : AppColors.textDim,
              ),
              onPressed: () => context.read<AppState>().toggleFavorite(channel),
            ),
        ],
      ),
    );
  }

  String _epgLine(AppState state) {
    if (state.activeChannel == null) return "Tune a channel to see what's on";
    final now = state.epg.nowTitle;
    final next = state.epg.nextTitle;
    if (now == null && next == null) return 'No programme guide for this channel';
    final parts = <String>[];
    if (now != null) parts.add('Now: $now');
    if (next != null) parts.add('Next: $next');
    return parts.join('   ·   ');
  }
}
