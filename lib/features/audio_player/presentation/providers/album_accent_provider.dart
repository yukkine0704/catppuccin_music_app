import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../core/utils/album_color_extractor.dart';
import '../../../../core/utils/album_color_mapper.dart';
import '../../../library/data/providers/album_art_provider.dart';
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
      final previousAlbumId = previous?.currentTrack?.albumId;
      final nextAlbumId = next.currentTrack?.albumId;
      final previousGenre = previous?.currentTrack?.genre;
      final nextGenre = next.currentTrack?.genre;

      if (nextAlbumId != previousAlbumId || nextGenre != previousGenre) {
        _updateAccentColor(
          nextAlbumId, nextGenre,
        );
      }
    });
  }

  Future<void> _updateAccentColor(
    int? albumId,
    String? genre,
  ) async {
    Uint8List? albumArtBytes;

    // Try to get artwork bytes from albumId
    if (albumId != null) {
      final audioQuery = _ref.read(onAudioQueryProvider);
      try {
        albumArtBytes = await audioQuery.queryArtwork(
          albumId,
          ArtworkType.ALBUM,
          size: 200, // Smaller size for color extraction
          quality: 80,
        );
      } catch (_) {
        // Artwork not available
      }
    }

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
