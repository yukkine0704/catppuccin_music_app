import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/track.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../domain/entities/album.dart';

/// Filter options for albums.
enum AlbumFilterType {
  name,
  artist,
  year,
  trackCount,
  dateAdded,
}

/// Sort direction for albums.
enum AlbumSortDirection {
  ascending,
  descending,
}

/// View mode for albums display.
enum AlbumViewMode {
  grid,
  list,
}

/// State for albums screen.
class AlbumsState {
  final List<Album> albums;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final AlbumFilterType filterType;
  final AlbumSortDirection sortDirection;
  final AlbumViewMode viewMode;
  final bool isShuffleEnabled;

  const AlbumsState({
    this.albums = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterType = AlbumFilterType.name,
    this.sortDirection = AlbumSortDirection.ascending,
    this.viewMode = AlbumViewMode.grid,
    this.isShuffleEnabled = false,
  });

  AlbumsState copyWith({
    List<Album>? albums,
    bool? isLoading,
    String? error,
    String? searchQuery,
    AlbumFilterType? filterType,
    AlbumSortDirection? sortDirection,
    AlbumViewMode? viewMode,
    bool? isShuffleEnabled,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      sortDirection: sortDirection ?? this.sortDirection,
      viewMode: viewMode ?? this.viewMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
    );
  }

  /// Get filtered and sorted albums.
  List<Album> get filteredAlbums {
    var result = List<Album>.from(albums);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((album) {
        return album.name.toLowerCase().contains(query) ||
            album.artist.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (filterType) {
        case AlbumFilterType.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case AlbumFilterType.artist:
          comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case AlbumFilterType.year:
          comparison = (a.year ?? 0).compareTo(b.year ?? 0);
        case AlbumFilterType.trackCount:
          comparison = a.trackCount.compareTo(b.trackCount);
        case AlbumFilterType.dateAdded:
          comparison = (a.dateAdded ?? DateTime(0))
              .compareTo(b.dateAdded ?? DateTime(0));
      }
      return sortDirection == AlbumSortDirection.ascending
          ? comparison
          : -comparison;
    });

    return result;
  }
}

/// Notifier for managing albums state.
class AlbumsNotifier extends StateNotifier<AlbumsState> {
  final Ref _ref;

  AlbumsNotifier(this._ref) : super(const AlbumsState());

  /// Loads albums from library tracks.
  void loadAlbums() {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final libraryState = _ref.read(libraryProvider);
      final tracks = libraryState.tracks;

      // Group tracks by album
      final Map<String, List<Track>> albumGroups = {};
      for (final track in tracks) {
        final key = '${track.album}_${track.artist}';
        albumGroups.putIfAbsent(key, () => []).add(track);
      }

      // Convert to Album entities
      final albums = albumGroups.entries.map((entry) {
        final albumTracks = entry.value;
        final firstTrack = albumTracks.first;

        return Album(
          name: firstTrack.album,
          artist: firstTrack.artist,
          albumId: firstTrack.albumId,
          year: firstTrack.year,
          trackCount: albumTracks.length,
          dateAdded: null, // Could be derived from file metadata
        );
      }).toList();

      state = state.copyWith(albums: albums, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Updates search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates filter type.
  void setFilterType(AlbumFilterType type) {
    state = state.copyWith(filterType: type);
  }

  /// Toggles sort direction.
  void toggleSortDirection() {
    state = state.copyWith(
      sortDirection: state.sortDirection == AlbumSortDirection.ascending
          ? AlbumSortDirection.descending
          : AlbumSortDirection.ascending,
    );
  }

  /// Sets sort direction.
  void setSortDirection(AlbumSortDirection direction) {
    state = state.copyWith(sortDirection: direction);
  }

  /// Toggles view mode between grid and list.
  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == AlbumViewMode.grid
          ? AlbumViewMode.list
          : AlbumViewMode.grid,
    );
  }

  /// Sets view mode.
  void setViewMode(AlbumViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Toggles shuffle mode.
  void toggleShuffle() {
    state = state.copyWith(isShuffleEnabled: !state.isShuffleEnabled);
  }

  /// Sets shuffle mode.
  void setShuffle(bool enabled) {
    state = state.copyWith(isShuffleEnabled: enabled);
  }
}

/// Provider for AlbumsNotifier.
final albumsProvider = StateNotifierProvider<AlbumsNotifier, AlbumsState>((ref) {
  return AlbumsNotifier(ref);
});

/// Provider for search query in albums.
final albumsSearchQueryProvider = StateProvider<String>((ref) => '');
