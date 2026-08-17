import 'package:flutter/material.dart';

import '../models/channel.dart';
import '../theme.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.active,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent.withOpacity(0.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  color: AppColors.bgElevated,
                  child: channel.logoUrl.isNotEmpty
                      ? Image.network(
                          channel.logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _fallback(),
                        )
                      : _fallback(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(channel.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    Text(channel.groupTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  channel.favorite ? Icons.star : Icons.star_border,
                  size: 18,
                  color: channel.favorite ? AppColors.accent : AppColors.textFaint,
                ),
                onPressed: onToggleFavorite,
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Center(
        child: Text(
          channel.name.isNotEmpty ? channel.name.substring(0, channel.name.length >= 2 ? 2 : 1).toUpperCase() : '?',
          style: const TextStyle(fontSize: 11, color: AppColors.textFaint),
        ),
      );
}
