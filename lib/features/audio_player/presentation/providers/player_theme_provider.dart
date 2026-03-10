import 'dart:async';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/utils/album_palette_generator.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import 'album_accent_provider.dart';
import 'audio_player_provider.dart';

/// State class for player theme transitions.
class PlayerThemeState {
  /// Whether the album-based color palette is currently active.
  final bool isAlbumPaletteActive;

  /// The current accent color being displayed.
  final Color currentAccentColor;

  /// The target accent color (for animation).
  final Color targetAccentColor;

  /// The ColorScheme generated from the accent color.
  final ColorScheme? albumColorScheme;

  /// Whether a transition is in progress.
  final bool isTransitioning;

  const PlayerThemeState({
    this.isAlbumPaletteActive = false,
    this.currentAccentColor = const Color(0xFF8839EF), // Default mauve
    this.targetAccentColor = const Color(0xFF8839EF),
    this.albumColorScheme,
    this.isTransitioning = false,
  });

  PlayerThemeState copyWith({
    bool? isAlbumPaletteActive,
    Color? currentAccentColor,
    Color? targetAccentColor,
    ColorScheme? albumColorScheme,
    bool? isTransitioning,
  }) {
    return PlayerThemeState(
      isAlbumPaletteActive: isAlbumPaletteActive ?? this.isAlbumPaletteActive,
      currentAccentColor: currentAccentColor ?? this.currentAccentColor,
      targetAccentColor: targetAccentColor ?? this.targetAccentColor,
      albumColorScheme: albumColorScheme ?? this.albumColorScheme,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}

/// Provider for managing player theme transitions with smooth animations.
/// Implements a 500ms delay before transitioning to album colors.
final playerThemeProvider =
    StateNotifierProvider<PlayerThemeNotifier, PlayerThemeState>((ref) {
      return PlayerThemeNotifier(ref);
    });

/// Notifier that manages theme transitions for the player.
class PlayerThemeNotifier extends StateNotifier<PlayerThemeState> {
  final Ref _ref;
  Timer? _transitionTimer;
  String? _currentFilePath;

  // Spring physics parameters for expressive transitions
  // Using M3E Expressive scheme with overshoot
  static const double _springStiffness = 350.0;
  static const double _springDamping = 15.0;

  // Animation duration for color transitions
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  // Delay before starting transition (to mask generation lag)
  static const Duration _transitionDelay = Duration(milliseconds: 500);

  PlayerThemeNotifier(this._ref) : super(const PlayerThemeState()) {
    // Listen to audio player state changes
    _ref.listen<PlayerState>(audioPlayerProvider, _onPlayerStateChanged);

    // Listen to accent color changes
    _ref.listen<AlbumAccentState>(albumAccentProvider, _onAccentStateChanged);

    // Listen to flavor changes
    _ref.listen<Flavor>(flavorProvider, _onFlavorChanged);
  }

  void _onPlayerStateChanged(PlayerState? previous, PlayerState next) {
    // Check if a new track started playing
    final newFilePath = next.currentTrack?.filePath;
    final wasPlaying = previous?.isPlaying ?? false;
    final isPlaying = next.isPlaying;

    // If track changed or playback started, schedule theme transition
    if (newFilePath != null && newFilePath != _currentFilePath) {
      _currentFilePath = newFilePath;
      _scheduleThemeTransition();
    } else if (!wasPlaying && isPlaying) {
      // Resume playback - also schedule transition
      _scheduleThemeTransition();
    }
  }

  void _onAccentStateChanged(
    AlbumAccentState? previous,
    AlbumAccentState next,
  ) {
    if (next.useAlbumColors || next.useGenreColors) {
      // Generate the new color scheme
      final flavor = _ref.read(flavorProvider);
      final colorScheme = AlbumPaletteGenerator.buildColorSchemeWithAccent(
        flavor,
        next.accentColor,
      );

      state = state.copyWith(
        targetAccentColor: next.accentColor,
        albumColorScheme: colorScheme,
      );

      // If transition is not active, start it
      if (!state.isTransitioning && state.isAlbumPaletteActive) {
        _startColorTransition();
      }
    }
  }

  void _onFlavorChanged(Flavor? previous, Flavor next) {
    // Regenerate color scheme when flavor changes
    final accentState = _ref.read(albumAccentProvider);
    if (accentState.useAlbumColors || accentState.useGenreColors) {
      final colorScheme = AlbumPaletteGenerator.buildColorSchemeWithAccent(
        next,
        accentState.accentColor,
      );

      state = state.copyWith(
        albumColorScheme: colorScheme,
        currentAccentColor: accentState.accentColor,
        targetAccentColor: accentState.accentColor,
      );
    }
  }

  /// Schedules a theme transition with delay.
  void _scheduleThemeTransition() {
    // Cancel any existing timer
    _transitionTimer?.cancel();

    // Start new timer for delayed transition
    _transitionTimer = Timer(_transitionDelay, () {
      _activateAlbumPalette();
    });
  }

  /// Activates the album-based palette.
  void _activateAlbumPalette() {
    final accentState = _ref.read(albumAccentProvider);
    final flavor = _ref.read(flavorProvider);

    // Generate color scheme
    final colorScheme = AlbumPaletteGenerator.buildColorSchemeWithAccent(
      flavor,
      accentState.accentColor,
    );

    state = state.copyWith(
      isAlbumPaletteActive: true,
      targetAccentColor: accentState.accentColor,
      albumColorScheme: colorScheme,
    );

    // Start the color transition animation
    _startColorTransition();
  }

  /// Starts the smooth color transition animation.
  void _startColorTransition() {
    state = state.copyWith(isTransitioning: true);
    // The actual animation is handled in the UI using AnimatedBuilder
    // with the transition duration
  }

  /// Resets to default theme (flavor's default mauve).
  void resetToDefault() {
    _transitionTimer?.cancel();
    final flavor = _ref.read(flavorProvider);

    state = PlayerThemeState(
      isAlbumPaletteActive: false,
      currentAccentColor: flavor.mauve,
      targetAccentColor: flavor.mauve,
      albumColorScheme: null,
      isTransitioning: false,
    );
  }

  /// Manually trigger a transition (e.g., for testing).
  void triggerTransition() {
    _scheduleThemeTransition();
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }
}

/// Extension to help with color interpolation during transitions.
extension ColorInterpolation on Color {
  /// Linearly interpolates between this color and another.
  Color lerpTo(Color other, double t) {
    return Color.lerp(this, other, t) ?? other;
  }
}
