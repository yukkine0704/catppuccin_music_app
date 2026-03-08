import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/track.dart';

/// Maximum number of tracks to keep in history.
const int maxHistoryItems = 30;

/// State for recently played tracks history.
class HistoryState {
  final List<Track> recentlyPlayed;
  final List<Track> mostPlayed;

  const HistoryState({
    this.recentlyPlayed = const [],
    this.mostPlayed = const [],
  });

  HistoryState copyWith({
    List<Track>? recentlyPlayed,
    List<Track>? mostPlayed,
  }) {
    return HistoryState(
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      mostPlayed: mostPlayed ?? this.mostPlayed,
    );
  }
}

/// Notifier for managing history state.
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  /// Adds a track to the recently played list.
  void addToRecentlyPlayed(Track track) {
    final recentList = List<Track>.from(state.recentlyPlayed);

    // Remove if already exists to avoid duplicates
    recentList.removeWhere((t) => t.id == track.id);

    // Add to the beginning (most recent)
    recentList.insert(0, track);

    // Keep only the last maxHistoryItems
    if (recentList.length > maxHistoryItems) {
      recentList.removeRange(maxHistoryItems, recentList.length);
    }

    state = state.copyWith(recentlyPlayed: recentList);

    // Also update most played
    _updateMostPlayed(track);
  }

  /// Updates the most played list.
  void _updateMostPlayed(Track track) {
    final mostPlayedList = List<Track>.from(state.mostPlayed);
    final existingIndex = mostPlayedList.indexWhere((t) => t.id == track.id);

    if (existingIndex >= 0) {
      // Move existing track to front (we just increment play count conceptually)
      final existing = mostPlayedList.removeAt(existingIndex);
      mostPlayedList.insert(0, existing);
    } else {
      // Add new track
      mostPlayedList.insert(0, track);
    }

    // Keep top 30
    if (mostPlayedList.length > maxHistoryItems) {
      mostPlayedList.removeRange(maxHistoryItems, mostPlayedList.length);
    }

    state = state.copyWith(mostPlayed: mostPlayedList);
  }

  /// Clears the recently played history.
  void clearRecentlyPlayed() {
    state = state.copyWith(recentlyPlayed: []);
  }

  /// Clears the most played history.
  void clearMostPlayed() {
    state = state.copyWith(mostPlayed: []);
  }

  /// Clears all history.
  void clearAll() {
    state = const HistoryState();
  }
}

/// Provider for HistoryNotifier.
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

/// Provider for recently played tracks.
final recentlyPlayedProvider = Provider<List<Track>>((ref) {
  final historyState = ref.watch(historyProvider);
  return historyState.recentlyPlayed;
});

/// Provider for most played tracks.
final mostPlayedProvider = Provider<List<Track>>((ref) {
  final historyState = ref.watch(historyProvider);
  return historyState.mostPlayed;
});
