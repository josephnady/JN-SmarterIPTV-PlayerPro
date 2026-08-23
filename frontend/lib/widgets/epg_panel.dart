import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';

class EpgPanel extends StatelessWidget {
  @Preview(name: "ChannelTile")

  const EpgPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final programmes = state.epg.programmes;
    final formatter = DateFormat('EEE HH:mm');

    return Container(
      color: AppColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(child: Text('Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).maybePop()),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: programmes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No EPG loaded for this channel.',
                        style: TextStyle(color: AppColors.textFaint, fontSize: 13)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: programmes.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, i) {
                      final p = programmes[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatter.format(p.startTime),
                              style: const TextStyle(fontSize: 11, color: AppColors.accent, fontFamily: 'monospace')),
                          const SizedBox(height: 3),
                          Text(p.title,
                              style: TextStyle(fontSize: 13, fontWeight: p.current ? FontWeight.w700 : FontWeight.w400)),
                          if (p.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              p.description.length > 180 ? '${p.description.substring(0, 180)}…' : p.description,
                              style: const TextStyle(fontSize: 12, color: AppColors.textFaint),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
