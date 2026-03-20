import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local_music_database_datasource.dart';
import '../../data/datasources/local_music_datasource.dart';
import '../../domain/entities/track.dart';

/// Tipos de filtro para la búsqueda
enum SearchFilterType { all, artists, albums, songs }

/// Provider for LocalMusicDatasource (escaneo del sistema de archivos).
final localMusicDatasourceProvider = Provider<LocalMusicDatasource>((ref) {
  return getIt<LocalMusicDatasource>();
});

/// State for blacklist management
class BlacklistState {
  final List<String> folders;
  final bool isLoading;

  const BlacklistState({this.folders = const [], this.isLoading = false});

  BlacklistState copyWith({List<String>? folders, bool? isLoading}) {
    return BlacklistState(
      folders: folders ?? this.folders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing blacklist state
class BlacklistNotifier extends StateNotifier<BlacklistState> {
  final LocalMusicDatasource _datasource;

  BlacklistNotifier(this._datasource) : super(const BlacklistState()) {
    _loadFolders();
  }

  void _loadFolders() {
    state = state.copyWith(folders: _datasource.getBlacklistedFolders());
  }

  Future<void> addFolder(String folder) async {
    await _datasource.addFolderToBlacklist(folder);
    _loadFolders();
  }

  Future<void> removeFolder(String folder) async {
    await _datasource.removeFolderFromBlacklist(folder);
    _loadFolders();
  }

  Future<void> resetToDefaults() async {
    await _datasource.resetBlacklistToDefaults();
    _loadFolders();
  }
}

/// Provider for BlacklistNotifier
final blacklistProvider =
    StateNotifierProvider<BlacklistNotifier, BlacklistState>((ref) {
      final datasource = ref.watch(localMusicDatasourceProvider);
      return BlacklistNotifier(datasource);
    });

/// Provider for LocalMusicDatabaseDatasource (cache en SQLite).
final localMusicDatabaseDatasourceProvider =
    Provider<LocalMusicDatabaseDatasource>((ref) {
      return getIt<LocalMusicDatabaseDatasource>();
    });

/// Información sobre cambios detectados durante el sync
class SyncInfo {
  final int added;
  final int removed;
  final int modified;

  const SyncInfo({
    required this.added,
    required this.removed,
    required this.modified,
  });

  bool get hasChanges => added > 0 || removed > 0 || modified > 0;

  String get description {
    if (!hasChanges) return 'No changes';
    final parts = <String>[];
    if (added > 0) parts.add('+$added new');
    if (removed > 0) parts.add('-$removed removed');
    if (modified > 0) parts.add('~$modified modified');
    return parts.join(', ');
  }
}

/// State for the library.
class LibraryState {
  final List<Track> tracks;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final int totalFiles;
  final int processedFiles;
  final bool isPermissionRequired;
  final SyncInfo? lastSyncInfo;

  const LibraryState({
    this.tracks = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.totalFiles = 0,
    this.processedFiles = 0,
    this.isPermissionRequired = false,
    this.lastSyncInfo,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progress => totalFiles > 0 ? processedFiles / totalFiles : 0.0;

  /// Whether scanning is in progress
  bool get isScanning => isLoading && totalFiles > 0;

  /// Whether we have cached data
  bool get hasCache => tracks.isNotEmpty;

  LibraryState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    int? totalFiles,
    int? processedFiles,
    bool? isPermissionRequired,
    SyncInfo? lastSyncInfo,
  }) {
    return LibraryState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      totalFiles: totalFiles ?? this.totalFiles,
      processedFiles: processedFiles ?? this.processedFiles,
      isPermissionRequired: isPermissionRequired ?? this.isPermissionRequired,
      lastSyncInfo: lastSyncInfo,
    );
  }
}

/// Notifier for managing library state with hybrid loading.
class LibraryNotifier extends StateNotifier<LibraryState> {
  final LocalMusicDatasource _filesystemDatasource;
  final LocalMusicDatabaseDatasource _databaseDatasource;

  LibraryNotifier(this._filesystemDatasource, this._databaseDatasource)
    : super(const LibraryState());

  /// Loads all songs using hybrid approach:
  /// 1. Load from cache (instant)
  /// 2. Scan filesystem in background
  /// 3. Detect and apply changes
  Future<void> loadSongs() async {
    // Step 1: Try to load from cache first (instant)
    final hasCache = await _databaseDatasource.hasCache();
    if (hasCache) {
      final cachedTracks = await _databaseDatasource.getCachedTracks();
      state = state.copyWith(
        tracks: cachedTracks,
        isLoading: true, // Keep loading true while we sync in background
        isSyncing: true,
        error: null,
        totalFiles: cachedTracks.length,
        processedFiles: cachedTracks.length,
        isPermissionRequired: false,
      );
    } else {
      // No cache, do full scan
      state = state.copyWith(
        isLoading: true,
        isSyncing: true,
        error: null,
        totalFiles: 0,
        processedFiles: 0,
        isPermissionRequired: false,
      );
    }

    // Step 2: Scan filesystem
    final scanResult = await _filesystemDatasource.getAllSongs(
      onProgress: (total, processed) {
        if (total > 0) {
          state = state.copyWith(totalFiles: total, processedFiles: processed);
        }
      },
    );

    // Step 3: Handle scan result
    await scanResult.fold(
      (failure) async {
        // Check if it's a permission failure
        final isPermissionError =
            failure.message.toLowerCase().contains('permiso') ||
            failure.message.toLowerCase().contains('permission') ||
            failure.message.toLowerCase().contains('denegado') ||
            failure.message.toLowerCase().contains('denied');

        if (!hasCache) {
          // Only show error if we don't have cache
          state = state.copyWith(
            isLoading: false,
            isSyncing: false,
            error: failure.message,
            isPermissionRequired: isPermissionError,
          );
        } else {
          // We have cache, just stop syncing but keep showing cached data
          state = state.copyWith(isLoading: false, isSyncing: false);
        }
      },
      (scannedTracks) async {
        // Step 4: Sync with database
        final changes = await _databaseDatasource.syncWithDatabase(
          scannedTracks,
        );

        // Reload from database to get the updated list
        final updatedTracks = await _databaseDatasource.getCachedTracks();

        state = state.copyWith(
          tracks: updatedTracks,
          isLoading: false,
          isSyncing: false,
          lastSyncInfo: SyncInfo(
            added: changes.added.length,
            removed: changes.removed.length,
            modified: changes.modified.length,
          ),
        );
      },
    );
  }

  /// Force full rescan (ignoring cache)
  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isSyncing: true,
      error: null,
      totalFiles: 0,
      processedFiles: 0,
      isPermissionRequired: false,
    );

    final result = await _filesystemDatasource.getAllSongs(
      onProgress: (total, processed) {
        if (total > 0) {
          state = state.copyWith(totalFiles: total, processedFiles: processed);
        }
      },
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          error: failure.message,
        );
      },
      (tracks) async {
        // Replace all cache
        await _databaseDatasource.replaceCache(tracks);
        state = state.copyWith(
          tracks: tracks,
          isLoading: false,
          isSyncing: false,
          lastSyncInfo: const SyncInfo(added: 0, removed: 0, modified: 0),
        );
      },
    );
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _databaseDatasource.replaceCache([]);
    state = const LibraryState();
  }
}

/// Provider for LibraryNotifier.
final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  final filesystemDatasource = ref.watch(localMusicDatasourceProvider);
  final databaseDatasource = ref.watch(localMusicDatabaseDatasourceProvider);
  return LibraryNotifier(filesystemDatasource, databaseDatasource);
});

/// Provider for searching tracks (works with cached data).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search filter type
final searchFilterProvider = StateProvider<SearchFilterType>(
  (ref) => SearchFilterType.all,
);

/// Provider for debounced search query
final debouncedSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered tracks based on search.
final filteredTracksProvider = Provider<List<Track>>((ref) {
  final state = ref.watch(libraryProvider);
  final query = ref.watch(debouncedSearchQueryProvider).toLowerCase();
  final filter = ref.watch(searchFilterProvider);

  if (query.isEmpty) {
    return [];
  }

  return state.tracks.where((track) {
    final titleMatch = track.title.toLowerCase().contains(query);
    final artistMatch = track.artist.toLowerCase().contains(query);
    final albumMatch = track.album.toLowerCase().contains(query);

    switch (filter) {
      case SearchFilterType.all:
        return titleMatch || artistMatch || albumMatch;
      case SearchFilterType.artists:
        return artistMatch;
      case SearchFilterType.albums:
        return albumMatch;
      case SearchFilterType.songs:
        return titleMatch;
    }
  }).toList();
});

/// Provider for unique artists from search results
final searchedArtistsProvider = Provider<List<String>>((ref) {
  final tracks = ref.watch(filteredTracksProvider);
  final artists = tracks.map((t) => t.artist).toSet().toList();
  artists.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return artists;
});

/// Provider for unique albums from search results
final searchedAlbumsProvider = Provider<List<String>>((ref) {
  final tracks = ref.watch(filteredTracksProvider);
  final albums = tracks.map((t) => t.album).toSet().toList();
  albums.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return albums;
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
