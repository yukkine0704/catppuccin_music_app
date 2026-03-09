import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local_music_datasource.dart';
import '../../domain/entities/track.dart';

/// Provider for LocalMusicDatasource.
final localMusicDatasourceProvider = Provider<LocalMusicDatasource>((ref) {
  return getIt<LocalMusicDatasource>();
});

/// State for the library.
class LibraryState {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;
  final int totalFiles;
  final int processedFiles;

  const LibraryState({
    this.tracks = const [],
    this.isLoading = false,
    this.error,
    this.totalFiles = 0,
    this.processedFiles = 0,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progress => totalFiles > 0 ? processedFiles / totalFiles : 0.0;

  /// Whether scanning is in progress
  bool get isScanning => isLoading && totalFiles > 0;

  LibraryState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    String? error,
    int? totalFiles,
    int? processedFiles,
  }) {
    return LibraryState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalFiles: totalFiles ?? this.totalFiles,
      processedFiles: processedFiles ?? this.processedFiles,
    );
  }
}

/// Notifier for managing library state.
class LibraryNotifier extends StateNotifier<LibraryState> {
  final LocalMusicDatasource _datasource;

  LibraryNotifier(this._datasource) : super(const LibraryState());

  /// Loads all songs from local storage.
  Future<void> loadSongs() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      totalFiles: 0,
      processedFiles: 0,
    );

    final result = await _datasource.getAllSongs(
      onProgress: (total, processed) {
        // Update progress
        state = state.copyWith(totalFiles: total, processedFiles: processed);
      },
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (tracks) {
        state = state.copyWith(tracks: tracks, isLoading: false);
      },
    );
  }

  /// Refreshes the library.
  Future<void> refresh() async {
    await loadSongs();
  }
}

/// Provider for LibraryNotifier.
final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  final datasource = ref.watch(localMusicDatasourceProvider);
  return LibraryNotifier(datasource);
});

/// Provider for searching tracks.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered tracks based on search.
final filteredTracksProvider = Provider<List<Track>>((ref) {
  final state = ref.watch(libraryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return state.tracks;
  }

  return state.tracks.where((track) {
    return track.title.toLowerCase().contains(query) ||
        track.artist.toLowerCase().contains(query) ||
        track.album.toLowerCase().contains(query);
  }).toList();
});

/// Provider for tracks sorted by date added (newest first).
final recentTracksProvider = Provider<List<Track>>((ref) {
  final state = ref.watch(libraryProvider);
  final tracks = List<Track>.from(state.tracks);

  // Sort by dateAdded descending (newest first)
  tracks.sort((a, b) {
    if (a.dateAdded == null && b.dateAdded == null) return 0;
    if (a.dateAdded == null) return 1;
    if (b.dateAdded == null) return -1;
    return b.dateAdded!.compareTo(a.dateAdded!);
  });

  return tracks;
});

/// Provider for the last 10 recent tracks (for carousel).
final lastTenTracksProvider = Provider<List<Track>>((ref) {
  final recentTracks = ref.watch(recentTracksProvider);
  return recentTracks.take(10).toList();
});
