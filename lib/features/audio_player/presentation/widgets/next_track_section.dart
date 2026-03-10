import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../providers/audio_player_provider.dart';

/// Next track section widget displaying preview of the next song in queue.
class NextTrackSection extends StatelessWidget {
  final PlayerState playerState;
  final Flavor flavor;
  final VoidCallback onTap;

  const NextTrackSection({
    super.key,
    required this.playerState,
    required this.flavor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextTrackIndex = playerState.currentTrackIndex + 1;
    final hasNextTrack = nextTrackIndex < playerState.queue.length;

    if (!hasNextTrack) {
      return const SizedBox.shrink();
    }

    final nextTrack = playerState.queue[nextTrackIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: flavor.surface1.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: flavor.mauve.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AlbumArtWidget(
                    filePath: nextTrack.filePath,
                    albumId: nextTrack.albumId,
                    size: 56,
                    borderRadius: 8,
                    flavor: flavor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEXT',
                        style: TextStyle(
                          color: flavor.subtext1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextTrack.title,
                        style: TextStyle(
                          color: flavor.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        nextTrack.artist,
                        style: TextStyle(color: flavor.subtext1, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.queue_music_rounded,
                  color: flavor.subtext1,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
