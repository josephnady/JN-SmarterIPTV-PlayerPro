import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';

class SettingsSheet extends StatefulWidget {
  @Preview(name: "SettingsSheet")
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: context.read<AppState>().baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Dialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                state.backendReachable ? 'Connected' : 'Backend not reachable',
                style: TextStyle(fontSize: 12, color: state.backendReachable ? AppColors.live : AppColors.danger),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Backend URL', hintText: 'http://192.168.1.10:8787'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.read<AppState>().setBaseUrl(_urlController.text),
                  child: const Text('Save & reconnect'),
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Expanded(child: Text('Resume last channel on launch', style: TextStyle(fontSize: 13))),
                  Switch(
                    value: state.autoplayLast,
                    onChanged: (v) => context.read<AppState>().setAutoplayLast(v),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text('Playlists', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Flexible(
                child: state.playlists.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No playlists added yet.', style: TextStyle(color: AppColors.textFaint, fontSize: 13)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.playlists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          final p = state.playlists[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.bgElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontSize: 13)),
                                      Text('${p.channelCount} channels · ${p.type}',
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.textFaint, fontFamily: 'monospace')),
                                    ],
                                  ),
                                ),
                                if (p.refreshable)
                                  IconButton(
                                    tooltip: 'Refresh',
                                    icon: const Icon(Icons.refresh, size: 18, color: AppColors.accent),
                                    onPressed: () => context.read<AppState>().refreshPlaylistById(p.id),
                                  ),
                                IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                  onPressed: () => context.read<AppState>().deletePlaylist(p.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
