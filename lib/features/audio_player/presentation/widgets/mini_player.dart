import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

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
    final flavor = catppuccin.mocha;
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
        height: 64,
        decoration: BoxDecoration(
          color: flavor.surface0,
          border: Border(
            top: BorderSide(
              color: flavor.surface1.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Progress bar
            SizedBox(
              height: 2,
              child: LinearProgressIndicatorM3E(
                value: progress,
              ),
            ),
            // Content row
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Album art thumbnail
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: flavor.mauve,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: playerState.currentTrack?.albumArtBytes != null
                            ? Image.memory(
                                playerState.currentTrack!.albumArtBytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(flavor),
                              )
                            : _buildPlaceholder(flavor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Track info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.currentTrack?.title ??
                                'No hay canción',
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
                            playerState.currentTrack?.artist ??
                                'Unknown Artist',
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
                    // Play/Pause button
                    IconButtonM3E(
                      variant: IconButtonM3EVariant.standard,
                      size: IconButtonM3ESize.md,
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: flavor.text,
                      ),
                      onPressed: () {
                        ref
                            .read(audioPlayerProvider.notifier)
                            .togglePlayPause();
                      },
                      tooltip: playerState.isPlaying ? 'Pausar' : 'Reproducir',
                    ),
                    // Next button
                    IconButtonM3E(
                      variant: IconButtonM3EVariant.standard,
                      size: IconButtonM3ESize.md,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: flavor.text,
                      ),
                      onPressed: () {
                        ref.read(audioPlayerProvider.notifier).skipToNext();
                      },
                      tooltip: 'Siguiente',
                    ),
                  ],
                ),
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
