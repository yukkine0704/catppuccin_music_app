import 'dart:math' as math;

import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/player_animation_provider.dart';
import 'queue_bottom_sheet.dart';

/// Animated player sheet with spring physics for smooth transitions
/// between mini player and full now playing screen.
class AnimatedPlayerSheet extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const AnimatedPlayerSheet({super.key, required this.onClose});

  @override
  ConsumerState<AnimatedPlayerSheet> createState() =>
      _AnimatedPlayerSheetState();
}

class _AnimatedPlayerSheetState extends ConsumerState<AnimatedPlayerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Track drag state
  double _dragExtent = 0.0;
  bool _isDragging = false;

  // Spring physics parameters - M3E inspired
  static const double _springStiffness = 400.0;
  static const double _springDamping = 22.0;

  // State for UI toggle (favorite is not in player state)
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Start at expanded state (1.0)
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSpringAnimation(double target) {
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: _springStiffness,
      damping: _springDamping,
    );

    final simulation = SpringSimulation(spring, _controller.value, target, 0.0);

    _controller.animateWith(simulation);
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _dragExtent += details.primaryDelta ?? 0;

    // Convert drag extent to animation value
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = _dragExtent / screenHeight;

    // Clamp between 0.0 (mini) and 1.0 (full)
    final newValue = (_controller.value + delta).clamp(0.0, 1.0);
    _controller.value = newValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    final currentValue = _controller.value;

    double target;
    if (velocity > 300) {
      // Fast drag down - close
      target = 0.0;
    } else if (velocity < -300) {
      // Fast drag up - open
      target = 1.0;
    } else if (currentValue > 0.5) {
      // Above middle - stay open
      target = 1.0;
    } else {
      // Below middle - close
      target = 0.0;
    }

    _runSpringAnimation(target);

    if (target == 0.0) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          widget.onClose();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);
    // Watch the animation style preference
    final animationStyle = ref.watch(playerAnimationStyleProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      body: GestureDetector(
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildContent(
              flavor,
              playerState,
              _controller.value,
              animationStyle,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    Flavor flavor,
    PlayerState playerState,
    double value,
    PlayerAnimationStyle animationStyle,
  ) {
    // Interpolate border radius based on expansion
    final borderRadius = 16 + (value * 12);

    return Container(
      decoration: BoxDecoration(
        color: flavor.base,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drag handle (fades out when expanded)
            Opacity(
              opacity: (1.0 - value).clamp(0.0, 1.0),
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: flavor.surface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Main content
            Flexible(
              child: _buildExpandedContent(
                flavor,
                playerState,
                value,
                animationStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    Flavor flavor,
    PlayerState playerState,
    double value,
    PlayerAnimationStyle animationStyle,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate album art size based on available width
        final albumArtSize = _lerp(68, screenWidth * 0.65, value);
        // Leave space for padding and other elements
        final availableHeight = constraints.maxHeight - 200;
        final clampedAlbumSize = albumArtSize.clamp(0.0, availableHeight);

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 + (value * 8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom AppBar
                _buildCustomAppBar(flavor, value),

                // Album Art Section - based on animation style
                SizedBox(
                  height: clampedAlbumSize + 40,
                  child: Center(
                    child: animationStyle == PlayerAnimationStyle.vinyl
                        ? _VinylAnimationWidget(
                            albumArt: playerState.currentTrack?.albumArtBytes,
                            flavor: flavor,
                            size: clampedAlbumSize,
                            borderRadius: 16 + (value * 18),
                            isPlaying: playerState.isPlaying,
                          )
                        : _AnimatedAlbumArt(
                            albumArt: playerState.currentTrack?.albumArtBytes,
                            flavor: flavor,
                            size: clampedAlbumSize,
                            borderRadius: 16 + (value * 18),
                            isPlaying: playerState.isPlaying,
                          ),
                  ),
                ),

                // Music Info Row
                _buildMusicInfoRow(flavor, playerState, value),

                SizedBox(height: 16 + (value * 8)),

                // Progress Section
                _buildProgressSection(playerState, flavor, value),

                SizedBox(height: 16 + (value * 8)),

                // Control Panel
                _buildControlPanel(playerState, flavor, value),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  Widget _buildCustomAppBar(Flavor flavor, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButtonM3E(
            variant: IconButtonM3EVariant.tonal,
            size: IconButtonM3ESize.md,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: flavor.text),
            onPressed: () {
              _runSpringAnimation(0.0);
              Future.delayed(const Duration(milliseconds: 250), () {
                if (mounted) {
                  widget.onClose();
                }
              });
            },
            tooltip: 'Collapse',
          ),
          Opacity(
            opacity: value,
            child: Text(
              'Listening to',
              style: TextStyle(
                color: flavor.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButtonM3E(
            variant: IconButtonM3EVariant.tonal,
            size: IconButtonM3ESize.md,
            icon: Icon(Icons.queue_music_rounded, color: flavor.text),
            onPressed: () => QueueBottomSheet.show(context),
            tooltip: 'Queue',
          ),
        ],
      ),
    );
  }

  Widget _buildMusicInfoRow(
    Flavor flavor,
    PlayerState playerState,
    double value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerState.currentTrack?.title ?? 'No hay canción',
                style: TextStyle(
                  color: flavor.text,
                  fontSize: _lerp(14, 22, value),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                playerState.currentTrack?.artist ?? 'Unknown Artist',
                style: TextStyle(
                  color: flavor.subtext1,
                  fontSize: _lerp(12, 16, value),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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

  Widget _buildProgressSection(PlayerState state, Flavor flavor, double value) {
    final position = state.position;
    final duration = state.duration.inMilliseconds > 0
        ? state.duration
        : const Duration(seconds: 1);

    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: flavor.mauve,
            inactiveTrackColor: flavor.surface1,
            thumbColor: flavor.mauve,
            overlayColor: flavor.mauve.withValues(alpha: 0.1),
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
          padding: EdgeInsets.symmetric(horizontal: 4 * value),
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

  Widget _buildControlPanel(PlayerState state, Flavor flavor, double value) {
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Column(
      children: [
        // Main row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.lg,
              icon: Icon(
                Icons.skip_previous_rounded,
                color: flavor.text,
                size: _lerp(28, 36, value),
              ),
              onPressed: () => notifier.skipToPrevious(),
            ),
            IconButtonM3E(
              variant: IconButtonM3EVariant.filled,
              size: IconButtonM3ESize.lg,
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: _lerp(32, 40, value),
                color: flavor.base,
              ),
              onPressed: () => notifier.togglePlayPause(),
            ),
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.lg,
              icon: Icon(
                Icons.skip_next_rounded,
                color: flavor.text,
                size: _lerp(28, 36, value),
              ),
              onPressed: () => notifier.skipToNext(),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Secondary row - ButtonGroupM3E in pill container
        Opacity(
          opacity: value,
          child: ButtonGroupM3E(
            type: ButtonGroupM3EType.connected,
            shape: ButtonGroupM3EShape.round,
            size: ButtonGroupM3ESize.sm,
            selection: true,
            style: ButtonM3EStyle.tonal,
            actions: [
              ButtonGroupM3EAction(
                label: Icon(
                  Icons.shuffle_rounded,
                  size: 22,
                  color: state.shuffleEnabled ? flavor.mauve : flavor.subtext1,
                ),
                selected: state.shuffleEnabled,
                onPressed: () => notifier.toggleShuffle(),
              ),
              ButtonGroupM3EAction(
                label: Icon(
                  state.repeatMode == PlayerRepeatMode.one
                      ? Icons.repeat_one_rounded
                      : Icons.repeat_rounded,
                  size: 22,
                  color: state.repeatMode != PlayerRepeatMode.off
                      ? flavor.mauve
                      : flavor.subtext1,
                ),
                selected: state.repeatMode != PlayerRepeatMode.off,
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
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Simple animated album art widget.
class _AnimatedAlbumArt extends StatefulWidget {
  final dynamic albumArt;
  final Flavor flavor;
  final double size;
  final double borderRadius;
  final bool isPlaying;

  const _AnimatedAlbumArt({
    required this.albumArt,
    required this.flavor,
    required this.size,
    required this.borderRadius,
    required this.isPlaying,
  });

  @override
  State<_AnimatedAlbumArt> createState() => _AnimatedAlbumArtState();
}

class _AnimatedAlbumArtState extends State<_AnimatedAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_AnimatedAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.flavor.mauve,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.flavor.crust.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.albumArt != null
              ? Image.memory(
                  widget.albumArt,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.crust,
        size: widget.size * 0.4,
      ),
    );
  }
}

/// Vinyl animation widget - Round vinyl with album art inside that rotates.
class _VinylAnimationWidget extends StatefulWidget {
  final dynamic albumArt;
  final Flavor flavor;
  final double size;
  final double borderRadius;
  final bool isPlaying;

  const _VinylAnimationWidget({
    required this.albumArt,
    required this.flavor,
    required this.size,
    required this.borderRadius,
    required this.isPlaying,
  });

  @override
  State<_VinylAnimationWidget> createState() => _VinylAnimationWidgetState();
}

class _VinylAnimationWidgetState extends State<_VinylAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_VinylAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = widget.flavor;
    final size = widget.size;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: child,
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: flavor.surface0,
            boxShadow: [
              BoxShadow(
                color: flavor.crust.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vinyl grooves (concentric circles)
              ...List.generate(10, (index) {
                final radius = size * 0.15 + (index * size * 0.06);
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: flavor.surface1.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                );
              }),

              // Center - Album art or placeholder (round)
              Container(
                width: size * 0.42,
                height: size * 0.42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: flavor.mauve,
                ),
                child: ClipOval(
                  child: widget.albumArt != null
                      ? Image.memory(
                          widget.albumArt,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.crust,
        size: widget.size * 0.15,
      ),
    );
  }
}
