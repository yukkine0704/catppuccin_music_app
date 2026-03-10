import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_player_provider.dart';

/// Progress section widget displaying seek slider with position and duration times.
class ProgressSection extends ConsumerWidget {
  final PlayerState playerState;
  final Flavor flavor;
  final Color accentColor;

  const ProgressSection({
    super.key,
    required this.playerState,
    required this.flavor,
    required this.accentColor,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = playerState.position;
    final duration = playerState.duration.inMilliseconds > 0
        ? playerState.duration
        : const Duration(seconds: 1);

    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: accentColor,
            inactiveTrackColor: flavor.surface1,
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: progress,
            onChanged: (newValue) {
              final seekTo = Duration(
                milliseconds: (newValue * duration.inMilliseconds).toInt(),
              );
              ref.read(audioPlayerProvider.notifier).seek(seekTo);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: flavor.subtext1, fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: flavor.subtext1, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
