import 'dart:math' as math;
import 'dart:typed_data';

import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../../shared/widgets/album_theme_wrapper.dart';
import '../../../library/data/providers/album_art_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/album_accent_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/player_animation_provider.dart';
import '../providers/player_theme_provider.dart';
import 'album_art_section.dart';
import 'music_info_row.dart';
import 'progress_section.dart';
import 'queue_bottom_sheet.dart';

/// Unified morphing player that transitions between mini-player and full-screen player.
/// Lives permanently in a Stack on the main screen and is controlled via AnimationController.
class MorphingPlayer extends ConsumerStatefulWidget {
  const MorphingPlayer({super.key});

  @override
  ConsumerState<MorphingPlayer> createState() => _MorphingPlayerState();
}

class _MorphingPlayerState extends ConsumerState<MorphingPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Track drag state
  double _dragExtent = 0.0;
  bool _isDragging = false;

  // Spring physics parameters - M3E Expressive scheme
  static const double _springStiffness = 350.0;
  static const double _springDamping = 15.0;

  // State for UI toggle (favorite is not in player state)
  bool _isFavorite = false;

  // Threshold for switching between Row and Column layout
  static const double _layoutThreshold = 0.3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Start at mini state (0.0)
    _controller.value = 0.0;
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
  }

  void _handleTap() {
    // Only expand when in mini state
    if (_controller.value < _layoutThreshold) {
      _runSpringAnimation(1.0);
    }
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);
    final themeState = ref.watch(playerThemeProvider);

    // Don't show anything if no track is loaded
    if (playerState.currentTrack == null) {
      return const SizedBox.shrink();
    }

    // Calculate navigation bar height - base 80.0 + system bottom padding
    // When animation is 0.0 (mini), bottom = 80.0 + bottomPadding
    // When animation is 1.0 (full), bottom = 0.0
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final baseNavBarHeight =
        80.0; // kBottomNavigationBarHeight is ~80 on most devices
    final miniPlayerBottom = baseNavBarHeight + bottomPadding;

    // Get screen height for full screen (without subtracting safe areas)
    final screenHeight = MediaQuery.of(context).size.height;

    // Background color based on theme state
    final backgroundColor =
        themeState.isAlbumPaletteActive && themeState.albumColorScheme != null
        ? themeState.albumColorScheme!.surface
        : flavor.base;

    return AlbumThemeWrapper(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;

          // Interpolate position values
          // Mini (0.0): bottom rests on NavigationBar (80.0 + bottomPadding)
          // Full (1.0): bottom is 0.0 (covers entire screen)
          final bottom = _lerp(miniPlayerBottom, 0.0, value);
          final left = _lerp(12.0, 0.0, value);
          final right = _lerp(12.0, 0.0, value);
          // Full screen height uses full screen size without subtracting safe areas
          final height = _lerp(72.0, screenHeight, value);

          // Interpolate border radius
          final borderRadius = _lerp(16.0, 28.0, value);

          return Positioned(
            left: left,
            right: right,
            bottom: bottom,
            height: height,
            child: GestureDetector(
              onTap: value < _layoutThreshold ? _handleTap : null,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        themeState.isAlbumPaletteActive &&
                            themeState.albumColorScheme != null
                        ? themeState.albumColorScheme!.surfaceContainerHighest
                        : flavor.surface0,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: themeState.isAlbumPaletteActive
                          ? themeState.currentAccentColor.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: flavor.crust.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: value < _layoutThreshold
                        ? _buildMiniPlayerLayout(
                            flavor,
                            playerState,
                            value,
                            themeState,
                          )
                        : _buildFullPlayerLayout(
                            flavor,
                            playerState,
                            value,
                            themeState,
                            backgroundColor,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayerLayout(
    Flavor flavor,
    PlayerState playerState,
    double value,
    PlayerThemeState themeState,
  ) {
    final accentState = ref.watch(albumAccentProvider);
    final accentColor = accentState.useAlbumColors || accentState.useGenreColors
        ? accentState.accentColor
        : flavor.mauve;

    // Calculate progress
    final duration = playerState.duration.inMilliseconds > 0
        ? playerState.duration
        : const Duration(seconds: 1);
    final progress = playerState.duration.inMilliseconds > 0
        ? (playerState.position.inMilliseconds / duration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Stack(
      children: [
        // Progress bar at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: flavor.surface1,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 2,
          ),
        ),
        // Content
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
                      style: TextStyle(color: flavor.subtext1, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Playback controls
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: accentColor,
                    onPrimary: accentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        ref
                            .read(audioPlayerProvider.notifier)
                            .togglePlayPause();
                      },
                      tooltip: playerState.isPlaying ? 'Pausar' : 'Reproducir',
                    ),
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
      ],
    );
  }

  Widget _buildFullPlayerLayout(
    Flavor flavor,
    PlayerState playerState,
    double value,
    PlayerThemeState themeState,
    Color backgroundColor,
  ) {
    final accentState = ref.watch(albumAccentProvider);
    final animationStyle = ref.watch(playerAnimationStyleProvider);

    // Watch album art provider
    final filePath = playerState.currentTrack?.filePath;
    final albumArtAsync = filePath != null && filePath.isNotEmpty
        ? ref.watch(albumArtFromFileProvider(filePath))
        : const AsyncValue<Uint8List?>.data(null);

    final accentColor = accentState.useAlbumColors || accentState.useGenreColors
        ? accentState.accentColor
        : flavor.mauve;

    final onAccentColor = accentColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    // Calculate interpolated values
    final albumArtSize = _lerp(48, screenWidth * 0.65, value);
    final borderRadius = _lerp(24, 28, value);
    final horizontalPadding = _lerp(12, 16, value);

    // Full screen layout - no SafeArea, uses transparent background to cover status bar
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Column(
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

          // Custom AppBar with manual top padding to avoid notch/clock
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8 + topPadding, // Manual top padding to avoid notch
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButtonM3E(
                  variant: IconButtonM3EVariant.tonal,
                  size: IconButtonM3ESize.md,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: flavor.text,
                  ),
                  onPressed: () => _runSpringAnimation(0.0),
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
          ),

          // Main content
          Flexible(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Album Art Section
                    SizedBox(
                      height: albumArtSize + 40,
                      child: Center(
                        child: _buildAlbumArt(
                          animationStyle,
                          playerState,
                          albumArtAsync,
                          albumArtSize,
                          flavor,
                          borderRadius,
                        ),
                      ),
                    ),

                    // Music Info Row
                    _buildMusicInfoRow(flavor, playerState, value),

                    const SizedBox(height: 16),

                    // Progress Section
                    _buildProgressSection(playerState, flavor, accentColor),

                    const SizedBox(height: 16),

                    // Control Panel
                    _buildControlPanel(
                      playerState,
                      flavor,
                      value,
                      accentColor,
                      onAccentColor,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(
    PlayerAnimationStyle animationStyle,
    PlayerState playerState,
    AsyncValue<Uint8List?> albumArtAsync,
    double size,
    Flavor flavor,
    double borderRadius,
  ) {
    return AlbumArtSection(
      playerState: playerState,
      animationStyle: animationStyle,
      size: size,
      borderRadius: borderRadius,
      flavor: flavor,
    );
  }

  Widget _buildMusicInfoRow(
    Flavor flavor,
    PlayerState playerState,
    double value,
  ) {
    return MusicInfoRow(
      playerState: playerState,
      flavor: flavor,
      animationValue: value,
      isFavorite: _isFavorite,
      onFavoriteToggle: (newValue) {
        setState(() {
          _isFavorite = newValue;
        });
      },
    );
  }

  Widget _buildProgressSection(
    PlayerState state,
    Flavor flavor,
    Color accentColor,
  ) {
    return ProgressSection(
      playerState: state,
      flavor: flavor,
      accentColor: accentColor,
    );
  }

  Widget _buildControlPanel(
    PlayerState state,
    Flavor flavor,
    double value,
    Color accentColor,
    Color onAccentColor,
  ) {
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
                  size: _lerp(28, 36, value),
                ),
                onPressed: () => notifier.skipToPrevious(),
              ),

              // Play/Pause
              IconButtonM3E(
                variant: state.isPlaying
                    ? IconButtonM3EVariant.filled
                    : IconButtonM3EVariant.tonal,
                size: IconButtonM3ESize.lg,
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: state.isPlaying ? onAccentColor : accentColor,
                  size: _lerp(32, 40, value),
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
                  size: _lerp(28, 36, value),
                ),
                onPressed: () => notifier.skipToNext(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Shuffle/Repeat buttons (fade in)
        Opacity(
          opacity: value,
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
                    color: state.shuffleEnabled ? accentColor : flavor.subtext1,
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
                        ? accentColor
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
        ),

        const SizedBox(height: 16),

        // Next track section
        _buildNextTrackSection(state, flavor),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: flavor.surface1.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => QueueBottomSheet.show(context),
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

/// Vinyl animation widget for the player.
class _VinylAnimationWidget extends StatefulWidget {
  final Uint8List? albumArt;
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
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinyl background
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.flavor.crust,
              boxShadow: [
                BoxShadow(
                  color: widget.flavor.crust.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Vinyl grooves
          Container(
            width: widget.size * 0.85,
            height: widget.size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          Container(
            width: widget.size * 0.55,
            height: widget.size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          // Album art center
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.albumArt != null && widget.albumArt!.isNotEmpty
                ? Image.memory(
                    widget.albumArt!,
                    width: widget.size * 0.45,
                    height: widget.size * 0.45,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size * 0.45,
      height: widget.size * 0.45,
      decoration: BoxDecoration(
        color: widget.flavor.surface0,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.subtext0,
        size: widget.size * 0.2,
      ),
    );
  }
}
