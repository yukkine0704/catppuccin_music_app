import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/providers/audio_player_provider.dart';
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

  const LyricsState({
    this.lyrics = const [],
    this.currentLineIndex = -1,
    this.isVisible = false,
    this.isLoading = false,
  });

  LyricsState copyWith({
    List<LyricLine>? lyrics,
    int? currentLineIndex,
    bool? isVisible,
    bool? isLoading,
  }) {
    return LyricsState(
      lyrics: lyrics ?? this.lyrics,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
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
          _loadLyricsForTrack(next.currentTrack!.filePath);
        }
      }
    });
  }

  /// Loads lyrics for a given audio file path.
  Future<void> _loadLyricsForTrack(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      state = state.copyWith(lyrics: [], currentLineIndex: -1);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final lyrics = await _dataSource.loadLyrics(filePath);
      state = state.copyWith(
        lyrics: lyrics,
        currentLineIndex: -1,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[LyricsNotifier] Error loading lyrics: $e');
      state = state.copyWith(
        lyrics: [],
        currentLineIndex: -1,
        isLoading: false,
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
