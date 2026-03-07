import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../library/domain/entities/track.dart';
import '../../data/datasources/audio_player_service.dart';

/// Provider for AudioHandler (background service).
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  return getIt<AudioHandler>();
});

/// State for the currently playing track.
class PlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
  });

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing audio playback state.
class AudioPlayerNotifier extends StateNotifier<PlayerState> {
  final AudioHandler _audioHandler;

  AudioPlayerNotifier(this._audioHandler) : super(const PlayerState()) {
    _init();
  }

  void _init() {
    // Listen to playback state changes
    _audioHandler.playbackState.listen((playbackState) {
      state = state.copyWith(
        isPlaying: playbackState.playing,
        position: playbackState.updatePosition,
      );
    });
  }

  /// Plays a list of tracks.
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;

    state = state.copyWith(currentTrack: tracks[startIndex], isLoading: true);

    try {
      final service = _audioHandler as AudioPlayerService;
      await service.playTracks(tracks, startIndex: startIndex);
      state = state.copyWith(
        currentTrack: tracks[startIndex],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Plays a single track.
  Future<void> playTrack(Track track) async {
    await playTracks([track], startIndex: 0);
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _audioHandler.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _audioHandler.play();
  }

  /// Toggles play/pause.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Seeks to a position.
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  /// Skips to next track.
  Future<void> skipToNext() async {
    await _audioHandler.skipToNext();
  }

  /// Skips to previous track.
  Future<void> skipToPrevious() async {
    await _audioHandler.skipToPrevious();
  }
}

/// Provider for AudioPlayerNotifier.
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, PlayerState>((ref) {
      final handler = ref.watch(audioHandlerProvider);
      return AudioPlayerNotifier(handler);
    });

/// Provider for position stream.
final positionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  final service = handler as AudioPlayerService;
  return service.positionStream;
});

/// Provider for duration stream.
final durationStreamProvider = StreamProvider<Duration?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  final service = handler as AudioPlayerService;
  return service.durationStream;
});
