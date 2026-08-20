import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';
import 'channel_player/channel_player.dart';
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
            // Keyed by channel id so the player fully reinitializes per channel change.
            child: ChannelPlayer(
              key: ValueKey(state.activeChannel?.id),
              streamUrl: state.activeChannel?.streamUrl,
            ),
          ),
        ),
        const TunerDial(),
      ],
    );
  }
}
