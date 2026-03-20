import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/track.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../domain/entities/smart_playlist.dart';

/// Widget de tarjeta para mostrar una Smart Playlist
class PlaylistCard extends ConsumerWidget {
  final SmartPlaylist playlist;
  final VoidCallback onTap;
  final List<Track> tracks;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);

    return Card(
      color: flavor.mantle,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: flavor.surface0.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: flavor.mauve.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(playlist.iconName),
                      color: flavor.mauve,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: TextStyle(
                            color: flavor.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${tracks.length} canciones',
                          style: TextStyle(
                            color: flavor.subtext0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: flavor.subtext1),
                ],
              ),
              if (tracks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  playlist.description,
                  style: TextStyle(color: flavor.subtext0, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'history':
        return Icons.history_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      default:
        return Icons.playlist_play_rounded;
    }
  }
}
