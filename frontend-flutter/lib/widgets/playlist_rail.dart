import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';
import 'add_playlist_sheet.dart';
import 'settings_sheet.dart';

class PlaylistRail extends StatelessWidget {
  const PlaylistRail({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      width: 56,
      color: AppColors.bgElevated,
      child: Column(
        children: [
          const SizedBox(height: 14),
          const Icon(Icons.settings_input_antenna, color: AppColors.accent),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: state.playlists.map((p) {
                final active = p.id == state.activePlaylistId;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 11),
                  child: Tooltip(
                    message: p.name,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => context.read<AppState>().selectPlaylist(p.id),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : AppColors.panel,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: active ? AppColors.accent : AppColors.line),
                        ),
                        child: Text(
                          p.name.isNotEmpty ? p.name.substring(0, p.name.length >= 2 ? 2 : 1).toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? const Color(0xFF191305) : AppColors.textDim,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            tooltip: 'Add playlist',
            icon: const Icon(Icons.add, color: AppColors.textDim),
            onPressed: () => showDialog(context: context, builder: (_) => const AddPlaylistSheet()),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune, color: AppColors.textDim),
            onPressed: () => showDialog(context: context, builder: (_) => const SettingsSheet()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
