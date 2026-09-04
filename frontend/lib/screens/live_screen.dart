import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/channel_sidebar.dart';
import '../widgets/epg_panel.dart';
import '../widgets/player_panel.dart';
import '../widgets/playlist_rail.dart';

class LiveScreen extends StatelessWidget {
  @Preview(name: "LiveScreen")
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.backendReachable) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: AppColors.textFaint, size: 40),
                const SizedBox(height: 12),
                Text("Can't reach the backend at\n${state.baseUrl}",
                    textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDim)),
                const SizedBox(height: 4),
                const Text('Check Settings for the backend URL.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.read<AppState>().init(),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const _SettingsFallbackDialog(),
                      ),
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        if (wide) {
          return const Scaffold(
            body: Row(
              children: [
                PlaylistRail(),
                VerticalDivider(width: 1, color: AppColors.line),
                ChannelSidebar(),
                VerticalDivider(width: 1, color: AppColors.line),
                Expanded(child: PlayerPanel()),
              ],
            ),
            endDrawer: Drawer(width: 340, child: EpgPanel()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('JN Smarter IPTV Player Pro', style: TextStyle(fontSize: 15)),
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.live_tv_rounded),
                  tooltip: 'Guide',
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ],
          ),
          drawer: const Drawer(
            backgroundColor: AppColors.panel,
            child: Row(
              children: [
                PlaylistRail(),
                Expanded(child: ChannelSidebar()),
              ],
            ),
          ),
          endDrawer: const Drawer(width: 320, child: EpgPanel()),
          body: const PlayerPanel(),
        );
      },
    );
  }
}

/// Lightweight settings entry point shown from the "can't reach backend" screen,
/// where the normal rail (and its Settings button) isn't on screen yet.
class _SettingsFallbackDialog extends StatefulWidget {
  const _SettingsFallbackDialog();

  @override
  State<_SettingsFallbackDialog> createState() => _SettingsFallbackDialogState();
}

class _SettingsFallbackDialogState extends State<_SettingsFallbackDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<AppState>().baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.panel,
      title: const Text('Backend URL'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'http://192.168.1.10:8787'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            context.read<AppState>().setBaseUrl(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
