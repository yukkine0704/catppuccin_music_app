import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../providers/audio_player_provider.dart';

/// Player controls widget displaying playback controls, shuffle, repeat, and next track.
class PlayerControls extends ConsumerWidget {
  final PlayerState playerState;
  final Flavor flavor;
  final double animationValue;
  final Color accentColor;
  final Color onAccentColor;
  final VoidCallback onNextTrackTap;

  const PlayerControls({
    super.key,
    required this.playerState,
    required this.flavor,
    required this.animationValue,
    required this.accentColor,
    required this.onAccentColor,
    required this.onNextTrackTap,
  });

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Skip Previous
              IconButtonM3E(
                variant: IconButtonM3EVariant.tonal,
                size: IconButtonM3ESize.lg,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: accentColor,
                  size: _lerp(28, 36, animationValue),
                ),
                onPressed: () => notifier.skipToPrevious(),
              ),

              // Play/Pause
              IconButtonM3E(
                variant: playerState.isPlaying
                    ? IconButtonM3EVariant.filled
                    : IconButtonM3EVariant.tonal,
                size: IconButtonM3ESize.lg,
                icon: Icon(
                  playerState.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: playerState.isPlaying ? onAccentColor : accentColor,
                  size: _lerp(32, 40, animationValue),
                ),
                onPressed: () => notifier.togglePlayPause(),
              ),

              // Skip Next
              IconButtonM3E(
                variant: IconButtonM3EVariant.tonal,
                size: IconButtonM3ESize.lg,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: accentColor,
                  size: _lerp(28, 36, animationValue),
                ),
                onPressed: () => notifier.skipToNext(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Shuffle/Repeat buttons (fade in)
        Opacity(
          opacity: animationValue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ButtonGroupM3E(
              type: ButtonGroupM3EType.connected,
              shape: ButtonGroupM3EShape.round,
              size: ButtonGroupM3ESize.md,
              selection: true,
              style: ButtonM3EStyle.tonal,
              actions: [
                ButtonGroupM3EAction(
                  label: Icon(
                    Icons.shuffle_rounded,
                    size: 22,
                    color: playerState.shuffleEnabled
                        ? accentColor
                        : flavor.subtext1,
                  ),
                  selected: playerState.shuffleEnabled,
                  onPressed: () => notifier.toggleShuffle(),
                ),
                ButtonGroupM3EAction(
                  label: Icon(
                    playerState.repeatMode == PlayerRepeatMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    size: 22,
                    color: playerState.repeatMode != PlayerRepeatMode.off
                        ? accentColor
                        : flavor.subtext1,
                  ),
                  selected: playerState.repeatMode != PlayerRepeatMode.off,
                  onPressed: () => notifier.cycleRepeatMode(),
                ),
                ButtonGroupM3EAction(
                  label: Icon(
                    Icons.lyrics_rounded,
                    size: 22,
                    color: flavor.subtext1,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Next track section
        _buildNextTrackSection(playerState, flavor),
      ],
    );
  }

  Widget _buildNextTrackSection(PlayerState state, Flavor flavor) {
    final nextTrackIndex = state.currentTrackIndex + 1;
    final hasNextTrack = nextTrackIndex < state.queue.length;

    if (!hasNextTrack) {
      return const SizedBox.shrink();
    }

    final nextTrack = state.queue[nextTrackIndex];

    return Opacity(
      opacity: animationValue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: flavor.surface1.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onNextTrackTap,
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
                    child: Icon(
                      Icons.music_note_rounded,
                      color: flavor.mauve,
                      size: 24,
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
      ),
    );
  }
}
