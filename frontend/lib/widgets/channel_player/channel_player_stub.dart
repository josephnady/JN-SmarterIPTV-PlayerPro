import 'package:flutter/material.dart';

import '../../theme.dart';

class ChannelPlayer extends StatelessWidget {
  final String? streamUrl;
  const ChannelPlayer({super.key, required this.streamUrl});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Video playback is not supported on this platform.',
          style: TextStyle(color: AppColors.textFaint)),
    );
  }
}
