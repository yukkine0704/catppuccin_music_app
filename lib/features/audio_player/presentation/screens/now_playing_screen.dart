import 'dart:math' as math;

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_player_provider.dart';

/// Now Playing screen with vinyl animation.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = catppuccin.mocha;
    final playerState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBar(
        title: const Text('Reproduciendo'),
        backgroundColor: Colors.transparent,
        foregroundColor: flavor.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vinyl section
            Expanded(
              flex: 3,
              child: Center(
                child: _VinylWidget(
                  isPlaying: playerState.isPlaying,
                  albumArt: playerState.currentTrack?.albumArtBytes,
                  flavor: flavor,
                ),
              ),
            ),

            // Track info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    playerState.currentTrack?.title ?? 'No hay canción',
                    style: TextStyle(
                      color: flavor.text,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playerState.currentTrack?.artist ?? 'Unknown Artist',
                    style: TextStyle(color: flavor.subtext1, fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildProgressBar(playerState, flavor, ref),
            ),

            const SizedBox(height: 24),

            // Controls
            _buildControls(ref, playerState, flavor),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(PlayerState state, Flavor flavor, WidgetRef ref) {
    return ProgressBar(
      progress: state.position,
      total: state.duration.inMilliseconds > 0
          ? state.duration
          : const Duration(seconds: 1),
      onSeek: (duration) {
        ref.read(audioPlayerProvider.notifier).seek(duration);
      },
      barHeight: 4,
      baseBarColor: flavor.surface2,
      progressBarColor: flavor.mauve,
      bufferedBarColor: flavor.mauve.withValues(alpha: 0.3),
      thumbColor: flavor.mauve,
      thumbRadius: 6,
      timeLabelTextStyle: TextStyle(color: flavor.subtext1, fontSize: 12),
    );
  }

  Widget _buildControls(WidgetRef ref, PlayerState state, Flavor flavor) {
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 36,
          color: flavor.text,
          onPressed: () => notifier.skipToPrevious(),
        ),

        const SizedBox(width: 16),

        // Play/Pause
        Container(
          decoration: BoxDecoration(
            color: flavor.mauve,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            iconSize: 48,
            color: flavor.crust,
            onPressed: () => notifier.togglePlayPause(),
          ),
        ),

        const SizedBox(width: 16),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 36,
          color: flavor.text,
          onPressed: () => notifier.skipToNext(),
        ),
      ],
    );
  }
}

/// Animated vinyl widget.
class _VinylWidget extends StatefulWidget {
  final bool isPlaying;
  final dynamic albumArt;
  final Flavor flavor;

  const _VinylWidget({
    required this.isPlaying,
    this.albumArt,
    required this.flavor,
  });

  @override
  State<_VinylWidget> createState() => _VinylWidgetState();
}

class _VinylWidgetState extends State<_VinylWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_VinylWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: _buildVinyl(context),
      ),
    );
  }

  Widget _buildVinyl(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    final flavor = widget.flavor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: flavor.surface0,
        boxShadow: [
          BoxShadow(
            color: flavor.crust.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinyl grooves
          ...List.generate(8, (index) {
            final radius = size * 0.15 + (index * size * 0.08);
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: flavor.surface1.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            );
          }),

          // Album art or center label
          Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: flavor.mauve,
            ),
            child: Center(
              child: Icon(
                Icons.music_note_rounded,
                color: flavor.crust,
                size: size * 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
