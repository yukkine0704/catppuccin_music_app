import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/audio_player_provider.dart';

/// Mini player widget displayed at the bottom of the screen above navigation bar.
/// Tapping it opens the full NowPlayingScreen via DraggableScrollableSheet.
class MiniPlayer extends ConsumerWidget {
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);

    // Don't show mini player if no track is loaded
    if (playerState.currentTrack == null) {
      return const SizedBox.shrink();
    }

    // Calculate progress
    final duration = playerState.duration.inMilliseconds > 0
        ? playerState.duration
        : const Duration(seconds: 1);
    final progress = playerState.duration.inMilliseconds > 0
        ? (playerState.position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: flavor.surface0,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: flavor.crust.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            // Content row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Album art thumbnail
                  AlbumArtWidget(
                    filePath: playerState.currentTrack?.filePath,
                    albumId: playerState.currentTrack?.albumId,
                    size: 48,
                    borderRadius: 24,
                    flavor: flavor,
                  ),
                  const SizedBox(width: 12),
                  // Track info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          playerState.currentTrack?.title ?? 'No hay canción',
                          style: TextStyle(
                            color: flavor.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          playerState.currentTrack?.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            color: flavor.subtext1,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Control buttons with rounded backgrounds
                  // Skip previous button
                  IconButtonM3E(
                    variant: IconButtonM3EVariant.tonal,
                    size: IconButtonM3ESize.sm,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: flavor.crust,
                    ),
                    onPressed: () {
                      ref.read(audioPlayerProvider.notifier).skipToPrevious();
                    },
                    tooltip: 'Anterior',
                  ),
                  // Play/Pause button
                  IconButtonM3E(
                    variant: IconButtonM3EVariant.filled,
                    size: IconButtonM3ESize.sm,
                    icon: Icon(
                      playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: flavor.crust,
                    ),
                    onPressed: () {
                      ref.read(audioPlayerProvider.notifier).togglePlayPause();
                    },
                    tooltip: playerState.isPlaying ? 'Pausar' : 'Reproducir',
                  ),
                  // Skip next button
                  IconButtonM3E(
                    variant: IconButtonM3EVariant.tonal,
                    size: IconButtonM3ESize.sm,
                    icon: Icon(Icons.skip_next_rounded, color: flavor.crust),
                    onPressed: () {
                      ref.read(audioPlayerProvider.notifier).skipToNext();
                    },
                    tooltip: 'Siguiente',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Flavor flavor) {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        color: flavor.crust,
        size: 24,
      ),
    );
  }
}
