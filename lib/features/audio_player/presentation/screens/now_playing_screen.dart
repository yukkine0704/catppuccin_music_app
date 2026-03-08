import 'dart:math' as math;

import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/audio_player_provider.dart';

/// Now Playing screen with vinyl animation - Redesigned version.
class NowPlayingScreen extends ConsumerStatefulWidget {
  final bool isInSheet;

  const NowPlayingScreen({super.key, this.isInSheet = false});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  // Placeholder states for UI (no functionality yet)
  bool _isFavorite = false;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      body: SafeArea(
        child: widget.isInSheet
            ? _buildDraggableContent(flavor, playerState)
            : _buildStandardContent(flavor, playerState),
      ),
    );
  }

  /// Builds content when used in a draggable sheet (swipe to dismiss).
  Widget _buildDraggableContent(Flavor flavor, PlayerState playerState) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Close sheet when swiped down
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.of(context).pop();
        }
      },
      child: _buildContent(flavor, playerState),
    );
  }

  /// Builds standard content (when used as standalone screen).
  Widget _buildStandardContent(Flavor flavor, PlayerState playerState) {
    return _buildContent(flavor, playerState);
  }

  /// Main content builder.
  Widget _buildContent(Flavor flavor, PlayerState playerState) {
    return Column(
      children: [
        // 1. Custom AppBar
        _buildCustomAppBar(flavor),

        // 2. Album Art Section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: _VinylWidget(
                isPlaying: playerState.isPlaying,
                albumArt: playerState.currentTrack?.albumArtBytes,
                flavor: flavor,
              ),
            ),
          ),
        ),

        // 3. Music Info Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildMusicInfoRow(flavor),
        ),

        const SizedBox(height: 24),

        // 4. Progress Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildProgressSection(playerState, flavor),
        ),

        const SizedBox(height: 24),

        // 5. Control Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildControlPanel(playerState, flavor),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  /// Custom AppBar: Row with collapse button (optional), "Listening to" text, and menu button.
  Widget _buildCustomAppBar(Flavor flavor) {
    // Hide collapse button when in sheet mode (drag handle is in parent)
    final showCollapseButton = !widget.isInSheet;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Collapse button (arrow down)
          if (showCollapseButton)
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.md,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: flavor.text),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Collapse',
            )
          else
            const SizedBox(width: 48), // Placeholder for alignment

          // "Listening to" text - Headline large and bold
          Text(
            'Listening to',
            style: TextStyle(
              color: flavor.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Menu/List button
          IconButtonM3E(
            variant: IconButtonM3EVariant.standard,
            size: IconButtonM3ESize.md,
            icon: Icon(Icons.queue_music_rounded, color: flavor.text),
            onPressed: () {
              // TODO: Show queue/menu
            },
            tooltip: 'Queue',
          ),
        ],
      ),
    );
  }

  /// Music Info Row: Title, Artist, and Favorite button.
  Widget _buildMusicInfoRow(Flavor flavor) {
    final playerState = ref.watch(audioPlayerProvider);

    return Row(
      children: [
        // Track info - Left aligned column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Song Title
              Text(
                playerState.currentTrack?.title ?? 'No hay canción',
                style: TextStyle(
                  color: flavor.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Artist
              Text(
                playerState.currentTrack?.artist ?? 'Unknown Artist',
                style: TextStyle(color: flavor.subtext1, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Favorite button - Heart
        IconButtonM3E(
          variant: IconButtonM3EVariant.standard,
          size: IconButtonM3ESize.lg,
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorite ? flavor.red : flavor.text,
          ),
          selectedIcon: Icon(Icons.favorite_rounded, color: flavor.red),
          isSelected: _isFavorite,
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
          tooltip: 'Add to favorites',
        ),
      ],
    );
  }

  /// Progress Section: LinearProgressIndicatorM3E with time labels.
  Widget _buildProgressSection(PlayerState state, Flavor flavor) {
    final position = state.position;
    // Ensure duration is at least 1 second to avoid issues
    final duration = state.duration.inMilliseconds > 0
        ? state.duration
        : const Duration(seconds: 1);

    // Calculate progress value (0.0 to 1.0)
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // LinearProgressIndicatorM3E
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: flavor.surface2,
            borderRadius: BorderRadius.circular(2),
          ),
          child: LinearProgressIndicatorM3E(value: progress),
        ),

        const SizedBox(height: 8),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current time - small font
              Text(
                _formatDuration(position),
                style: TextStyle(color: flavor.subtext1, fontSize: 12),
              ),
              // Total duration - small font
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

  /// Control Panel: Main row with Previous/Play-Pause/Next + Secondary row with Shuffle/Repeat/Lyrics.
  Widget _buildControlPanel(PlayerState state, Flavor flavor) {
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Column(
      children: [
        // Main row - Large buttons: Previous, Play/Pause, Next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous button - M3E
            ButtonM3E(
              onPressed: () => notifier.skipToPrevious(),
              icon: Icon(
                Icons.skip_previous_rounded,
                color: flavor.text,
                size: 36,
              ),
              label: const SizedBox.shrink(),
              style: ButtonM3EStyle.text,
              size: ButtonM3ESize.md,
            ),

            // Play/Pause - M3E filled button
            ButtonM3E(
              onPressed: () => notifier.togglePlayPause(),
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: flavor.crust,
                size: 40,
              ),
              label: const SizedBox.shrink(),
              style: ButtonM3EStyle.filled,
              size: ButtonM3ESize.lg,
            ),

            // Next button - M3E
            ButtonM3E(
              onPressed: () => notifier.skipToNext(),
              icon: Icon(Icons.skip_next_rounded, color: flavor.text, size: 36),
              label: const SizedBox.shrink(),
              style: ButtonM3EStyle.text,
              size: ButtonM3ESize.md,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Secondary row - Small discrete buttons: Shuffle, Repeat, Lyrics
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle button
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.md,
              icon: Icon(
                Icons.shuffle_rounded,
                color: _isShuffleEnabled ? flavor.mauve : flavor.subtext1,
                size: 24,
              ),
              selectedIcon: Icon(Icons.shuffle_rounded, color: flavor.mauve),
              isSelected: _isShuffleEnabled,
              onPressed: () {
                setState(() {
                  _isShuffleEnabled = !_isShuffleEnabled;
                });
              },
              tooltip: 'Shuffle',
            ),

            // Repeat button
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.md,
              icon: Icon(
                Icons.repeat_rounded,
                color: _isRepeatEnabled ? flavor.mauve : flavor.subtext1,
                size: 24,
              ),
              selectedIcon: Icon(Icons.repeat_rounded, color: flavor.mauve),
              isSelected: _isRepeatEnabled,
              onPressed: () {
                setState(() {
                  _isRepeatEnabled = !_isRepeatEnabled;
                });
              },
              tooltip: 'Repeat',
            ),

            // Lyrics button
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.md,
              icon: Icon(
                Icons.lyrics_rounded,
                color: flavor.subtext1,
                size: 24,
              ),
              onPressed: () {
                // TODO: Show lyrics
              },
              tooltip: 'Lyrics',
            ),
          ],
        ),
      ],
    );
  }

  /// Format duration to mm:ss format.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Animated vinyl widget - Round vinyl with album art inside.
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
    final size = MediaQuery.of(context).size.width * 0.65;
    final flavor = widget.flavor;

    // Round vinyl (circle)
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Completely round
        color: flavor.surface0,
        boxShadow: [
          BoxShadow(
            color: flavor.crust.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinyl grooves (concentric circles)
          ...List.generate(8, (index) {
            final radius = size * 0.12 + (index * size * 0.07);
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

          // Center - Album art or placeholder (round)
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Round center
              color: flavor.mauve,
            ),
            child: ClipOval(
              child: widget.albumArt != null
                  ? Image.memory(
                      widget.albumArt,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(flavor, size),
                    )
                  : _buildPlaceholder(flavor, size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Flavor flavor, double size) {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        color: flavor.crust,
        size: size * 0.15,
      ),
    );
  }
}
