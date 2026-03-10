import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/data/providers/album_art_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import 'audio_player_provider.dart';

/// State class for album-based accent colors.
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

/// Provider for album-based accent colors.
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
      final previousFilePath = previous?.currentTrack?.filePath;
      final nextFilePath = next.currentTrack?.filePath;
      final previousGenre = previous?.currentTrack?.genre;
      final nextGenre = next.currentTrack?.genre;

      if (nextFilePath != previousFilePath || nextGenre != previousGenre) {
        _updateAccentColor(
          nextFilePath, nextGenre,
        );
      }
    });
  }

  Future<void> _updateAccentColor(
    String? filePath,
    String? genre,
  ) async {
    final repository = _ref.read(artworkRepositoryProvider);
    final flavor = _ref.read(flavorProvider);

    // Priority 1: Try to get artwork colors from filePath
    if (filePath != null && filePath.isNotEmpty) {
      state = state.copyWith(isLoading: true);

      final artworkAsync = _ref.read(albumArtWithColorsProvider(filePath));

      final albumArt = await artworkAsync.when(
        data: (data) async => data,
        loading: () async => null,
        error: (_, __) async => null,
      );

      if (albumArt != null && albumArt.hasArtwork) {
        // Colors were extracted when we got the artwork
        if (albumArt.accentColor != null) {
          state = AlbumAccentState(
            accentColor: albumArt.accentColor!,
            useAlbumColors: true,
            useGenreColors: false,
            isLoading: false,
          );
          return;
        }
      }
    }

    // Priority 2: Try genre mapping
    if (genre != null && genre.isNotEmpty) {
      final genreAccent = repository.getAccentFromGenre(genre, flavor);

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
      accentColor: repository.getDefaultAccent(flavor),
      useAlbumColors: false,
      useGenreColors: false,
      isLoading: false,
    );
  }

  /// Manually set accent color (for settings or fallback).
  void setAccentColor(Color color) {
    state = AlbumAccentState(
      accentColor: color,
      useAlbumColors: false,
      useGenreColors: false,
    );
  }
}
