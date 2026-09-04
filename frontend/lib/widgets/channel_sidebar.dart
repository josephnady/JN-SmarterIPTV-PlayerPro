import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';
import 'channel_tile.dart';

class ChannelSidebar extends StatelessWidget {
  @Preview(name: "ChannelSidebar")
  const ChannelSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      width: 300,
      color: AppColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search channels…',
                    prefixIcon: Icon(Icons.search, size: 15, color: AppColors.textFaint),
                  ),
                  onChanged: (v) => context.read<AppState>().setSearch(v),
                ),
                if (state.groups.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: state.groupFilter,
                    isExpanded: true,
                    dropdownColor: AppColors.bgElevated,
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('All groups')),
                      ...state.groups.map(
                        (g) => DropdownMenuItem<String?>(value: g, child: Text(g, overflow: TextOverflow.clip)),
                      ),
                    ],
                    onChanged: (v) => context.read<AppState>().setGroupFilter(v),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _tabChip(context, 'All', ChannelTab.all, state.tab),
                const SizedBox(width: 6),
                _tabChip(context, 'Favorites', ChannelTab.favorites, state.tab),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.loadingChannels
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : state.channels.isEmpty
                    ? Center(
                        child: Text(
                          state.playlists.isEmpty ? 'No playlists yet' : 'No channels match',
                          style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.channels.length,
                        itemBuilder: (context, i) {
                          final c = state.channels[i];
                          return ChannelTile(
                            channel: c,
                            active: state.activeChannel?.id == c.id,
                            onTap: () => context.read<AppState>().playChannel(c),
                            onToggleFavorite: () => context.read<AppState>().toggleFavorite(c),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${state.channels.length} channel${state.channels.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 11, color: AppColors.textFaint, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
  Widget _tabChip(BuildContext context, String label, ChannelTab value, ChannelTab current) {
    final active = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AppState>().setTab(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.bgElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: active ? AppColors.line : Colors.transparent),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: active ? AppColors.accent : AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}
