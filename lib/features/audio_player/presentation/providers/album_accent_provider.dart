import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/album_color_extractor.dart';
import '../../../../core/utils/album_color_mapper.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import 'audio_player_provider.dart';

/// State class for album-based accent colors
class AlbumAccentState {
  final Color accentColor;
  final bool useAlbumColors;
  final bool useGenreColors;
  final bool isLoading;

  const AlbumAccentState({
    required this.accentColor,
    this.useAlbumColors = false,
    this.useGenreColors = false,
    this.isLoading = false,
  });

  AlbumAccentState copyWith({
    Color? accentColor,
    bool? useAlbumColors,
    bool? useGenreColors,
    bool? isLoading,
  }) {
    return AlbumAccentState(
      accentColor: accentColor ?? this.accentColor,
      useAlbumColors: useAlbumColors ?? this.useAlbumColors,
      useGenreColors: useGenreColors ?? this.useGenreColors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for album-based accent colors
final albumAccentProvider =
    StateNotifierProvider<AlbumAccentNotifier, AlbumAccentState>((ref) {
      return AlbumAccentNotifier(ref);
    });

class AlbumAccentNotifier extends StateNotifier<AlbumAccentState> {
  final Ref _ref;

  AlbumAccentNotifier(this._ref)
    : super(
        const AlbumAccentState(
          accentColor: Color(0xFF8839EF), // Default mauve
        ),
      ) {
    // Listen to track changes
    _ref.listen<PlayerState>(audioPlayerProvider, (previous, next) {
      if (next.currentTrack?.albumArtBytes !=
              previous?.currentTrack?.albumArtBytes ||
          next.currentTrack?.genre != previous?.currentTrack?.genre) {
        _updateAccentColor(
          next.currentTrack?.albumArtBytes,
          next.currentTrack?.genre,
        );
      }
    });
  }

  Future<void> _updateAccentColor(
    Uint8List? albumArtBytes,
    String? genre,
  ) async {
    final flavor = _ref.read(flavorProvider);

    // Priority 1: Try album art colors
    if (albumArtBytes != null) {
      state = state.copyWith(isLoading: true);

      final dominantColor = await AlbumColorExtractor.extractDominantColor(
        albumArtBytes,
      );

      if (dominantColor != null &&
          AlbumColorExtractor.isColorful(dominantColor)) {
        final accentColor = AlbumColorMapper.findClosestAccent(
          dominantColor,
          flavor,
        );

        state = AlbumAccentState(
          accentColor: accentColor,
          useAlbumColors: true,
          useGenreColors: false,
          isLoading: false,
        );
        return;
      }
    }

    // Priority 2: Try genre mapping
    if (genre != null && genre.isNotEmpty) {
      final genreAccent = AlbumColorMapper.getGenreAccent(genre, flavor);

      state = AlbumAccentState(
        accentColor: genreAccent,
        useAlbumColors: false,
        useGenreColors: true,
        isLoading: false,
      );
      return;
    }

    // Fallback: Default accent
    state = AlbumAccentState(
      accentColor: flavor.mauve,
      useAlbumColors: false,
      useGenreColors: false,
      isLoading: false,
    );
  }

  /// Manually set accent color (for settings or fallback)
  void setAccentColor(Color color) {
    state = AlbumAccentState(
      accentColor: color,
      useAlbumColors: false,
      useGenreColors: false,
    );
  }
}
