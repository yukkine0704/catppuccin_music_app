import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../library/domain/entities/track.dart';
import '../../data/datasources/lyrics_datasource.dart';
import '../../domain/entities/lyric_line.dart';

/// State for the lyrics feature.
class LyricsState {
  /// List of parsed lyric lines.
  final List<LyricLine> lyrics;

  /// Current active line index based on playback position.
  final int currentLineIndex;

  /// Whether lyrics are currently visible.
  final bool isVisible;

  /// Whether lyrics are currently loading.
  final bool isLoading;

  /// Whether lyrics are being searched online.
  final bool isSearchingOnline;

  /// Whether online search has been attempted for current track.
  final bool onlineSearchAttempted;

  /// Source of the lyrics (local or online).
  final LyricsSource source;

  const LyricsState({
    this.lyrics = const [],
    this.currentLineIndex = -1,
    this.isVisible = false,
    this.isLoading = false,
    this.isSearchingOnline = false,
    this.onlineSearchAttempted = false,
    this.source = LyricsSource.none,
  });

  LyricsState copyWith({
    List<LyricLine>? lyrics,
    int? currentLineIndex,
    bool? isVisible,
    bool? isLoading,
    bool? isSearchingOnline,
    bool? onlineSearchAttempted,
    LyricsSource? source,
  }) {
    return LyricsState(
      lyrics: lyrics ?? this.lyrics,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
      isSearchingOnline: isSearchingOnline ?? this.isSearchingOnline,
      onlineSearchAttempted:
          onlineSearchAttempted ?? this.onlineSearchAttempted,
      source: source ?? this.source,
    );
  }

  /// Returns the current lyric line text, or empty string if no line is active.
  String get currentLineText {
    if (currentLineIndex >= 0 && currentLineIndex < lyrics.length) {
      return lyrics[currentLineIndex].text;
    }
    return '';
  }

  /// Returns true if there are lyrics available.
  bool get hasLyrics => lyrics.isNotEmpty;

  /// Returns true if no lyrics found and online search hasn't been attempted.
  bool get canSearchOnline =>
      !hasLyrics && !onlineSearchAttempted && !isSearchingOnline;
}

/// Source of lyrics.
enum LyricsSource {
  /// No lyrics available.
  none,

  /// Lyrics loaded from local .lrc file.
  local,

  /// Lyrics fetched from online service.
  online,
}

/// Notifier for managing lyrics state.
class LyricsNotifier extends StateNotifier<LyricsState> {
  final LyricsDataSource _dataSource;
  final Ref _ref;

  LyricsNotifier(this._dataSource, this._ref) : super(const LyricsState()) {
    // Listen to position changes from the audio player
    _ref.listen<AsyncValue<Duration>>(positionStreamProvider, (previous, next) {
      next.whenData((position) {
        _updateCurrentLine(position);
      });
    });

    // Listen to track changes to load new lyrics
    _ref.listen<PlayerState>(audioPlayerProvider, (previous, next) {
      if (next.currentTrack != null) {
        if (previous?.currentTrack?.filePath != next.currentTrack!.filePath) {
          // Track changed, load new lyrics
          _loadLyricsForTrack(next.currentTrack!);
        }
      }
    });
  }

  /// Loads lyrics for a given track.
  /// First tries local .lrc files, then searches online.
  Future<void> _loadLyricsForTrack(Track track) async {
    // Reset state for new track
    state = state.copyWith(
      lyrics: [],
      currentLineIndex: -1,
      isLoading: true,
      isSearchingOnline: false,
      onlineSearchAttempted: false,
      source: LyricsSource.none,
    );

    // Try to load local lyrics first
    try {
      final localLyrics = await _dataSource.loadLyrics(track.filePath);
      if (localLyrics.isNotEmpty) {
        state = state.copyWith(
          lyrics: localLyrics,
          currentLineIndex: -1,
          isLoading: false,
          source: LyricsSource.local,
        );
        return;
      }
    } catch (e) {
      debugPrint('[LyricsNotifier] Error loading local lyrics: $e');
    }

    // No local lyrics found, try online search
    await _searchOnlineLyrics(track);
  }

  /// Searches for lyrics online using LRCLIB API.
  Future<void> _searchOnlineLyrics(Track track) async {
    if (track.artist.isEmpty && track.title.isEmpty) {
      state = state.copyWith(isLoading: false, onlineSearchAttempted: true);
      return;
    }

    state = state.copyWith(isLoading: true, isSearchingOnline: true);

    try {
      // Try exact match first
      var onlineLyrics = await _dataSource.searchOnlineLyrics(
        artist: track.artist,
        trackName: track.title,
        albumName: track.album.isNotEmpty ? track.album : null,
        durationMs: track.duration > 0 ? track.duration : null,
      );

      // If no exact match, try fuzzy search
      if (onlineLyrics.isEmpty) {
        onlineLyrics = await _dataSource.searchLyricsFuzzy(
          artist: track.artist,
          trackName: track.title,
          albumName: track.album.isNotEmpty ? track.album : null,
        );
      }

      if (onlineLyrics.isNotEmpty) {
        state = state.copyWith(
          lyrics: onlineLyrics,
          currentLineIndex: -1,
          isLoading: false,
          isSearchingOnline: false,
          onlineSearchAttempted: true,
          source: LyricsSource.online,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isSearchingOnline: false,
          onlineSearchAttempted: true,
        );
      }
    } catch (e) {
      debugPrint('[LyricsNotifier] Error searching online lyrics: $e');
      state = state.copyWith(
        isLoading: false,
        isSearchingOnline: false,
        onlineSearchAttempted: true,
      );
    }
  }

  /// Manually triggers online lyrics search.
  /// Useful when user wants to retry searching.
  /// Optionally accepts customArtist and customTitle for manual search.
  Future<void> searchOnlineLyrics({
    String? customArtist,
    String? customTitle,
  }) async {
    final playerState = _ref.read(audioPlayerProvider);
    final track = playerState.currentTrack;

    // Use custom values if provided, otherwise use track values
    final artist = customArtist ?? track?.artist ?? '';
    final title = customTitle ?? track?.title ?? '';

    // Need at least artist and title to search
    if (artist.isEmpty || title.isEmpty) {
      return;
    }

    // Set searching state
    state = state.copyWith(isLoading: true, isSearchingOnline: true);

    try {
      // Try exact match first
      var onlineLyrics = await _dataSource.searchOnlineLyrics(
        artist: artist,
        trackName: title,
      );

      // If no exact match, try fuzzy search
      if (onlineLyrics.isEmpty) {
        onlineLyrics = await _dataSource.searchLyricsFuzzy(
          artist: artist,
          trackName: title,
        );
      }

      if (onlineLyrics.isNotEmpty) {
        state = state.copyWith(
          lyrics: onlineLyrics,
          isLoading: false,
          isSearchingOnline: false,
          onlineSearchAttempted: true,
          source: LyricsSource.online,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        isSearchingOnline: false,
        onlineSearchAttempted: true,
        source: LyricsSource.none,
      );
    } catch (e) {
      debugPrint('[LyricsProvider] Error searching online: $e');
      state = state.copyWith(
        isLoading: false,
        isSearchingOnline: false,
        onlineSearchAttempted: true,
      );
    }
  }

  /// Updates the current line index based on the playback position.
  void _updateCurrentLine(Duration position) {
    if (state.lyrics.isEmpty) {
      return;
    }

    // Find the current line based on position
    int newIndex = -1;
    for (int i = 0; i < state.lyrics.length; i++) {
      if (state.lyrics[i].timestamp <= position) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != state.currentLineIndex) {
      state = state.copyWith(currentLineIndex: newIndex);
    }
  }

  /// Toggles the visibility of the lyrics panel.
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// Shows the lyrics panel.
  void showLyrics() {
    state = state.copyWith(isVisible: true);
  }

  /// Hides the lyrics panel.
  void hideLyrics() {
    state = state.copyWith(isVisible: false);
  }

  /// Manually scrolls to a specific line.
  void scrollToLine(int index) {
    if (index >= 0 && index < state.lyrics.length) {
      state = state.copyWith(currentLineIndex: index);
    }
  }

  /// Seeks to the timestamp of a specific lyric line.
  /// Updates both the line index and seeks the audio player.
  void seekToLine(int index) {
    if (index < 0 || index >= state.lyrics.length) {
      return;
    }

    final timestamp = state.lyrics[index].timestamp;

    // Update the current line index
    state = state.copyWith(currentLineIndex: index);

    // Seek the audio player to this position
    _ref.read(audioPlayerProvider.notifier).seek(timestamp);
  }
}

/// Provider for LyricsDataSource.
final lyricsDataSourceProvider = Provider<LyricsDataSource>((ref) {
  return LyricsDataSource();
});

/// Provider for LyricsNotifier.
final lyricsProvider = StateNotifierProvider<LyricsNotifier, LyricsState>((
  ref,
) {
  final dataSource = ref.watch(lyricsDataSourceProvider);
  return LyricsNotifier(dataSource, ref);
});

/// Provider to check if lyrics are available for the current track.
final hasLyricsProvider = Provider<bool>((ref) {
  final lyricsState = ref.watch(lyricsProvider);
  return lyricsState.hasLyrics;
});
