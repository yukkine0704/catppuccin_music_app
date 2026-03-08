import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../library/domain/entities/track.dart';
import '../../data/datasources/audio_player_service.dart';

/// Provider for AudioHandler (background service).
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  return getIt<AudioHandler>();
});

/// Repeat mode enum for the player state.
enum PlayerRepeatMode { off, all, one }

/// State for the currently playing track.
class PlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;
  final PlayerRepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<Track> queue;
  final int currentTrackIndex;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
    this.repeatMode = PlayerRepeatMode.off,
    this.shuffleEnabled = false,
    this.queue = const [],
    this.currentTrackIndex = 0,
  });

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
    PlayerRepeatMode? repeatMode,
    bool? shuffleEnabled,
    List<Track>? queue,
    int? currentTrackIndex,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      queue: queue ?? this.queue,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
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
      debugPrint(
        '[AudioPlayerNotifier] playbackState received - playing: ${playbackState.playing}, position: ${playbackState.updatePosition}',
      );
      state = state.copyWith(
        isPlaying: playbackState.playing,
        position: playbackState.updatePosition,
      );
    });

    // Also listen to duration changes from the player
    final service = _audioHandler as AudioPlayerService;
    service.durationStream.listen((duration) {
      debugPrint('[AudioPlayerNotifier] duration received: $duration');
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    // Also listen to the service for queue and current track changes
    service.currentTrackStream.listen((track) {
      debugPrint(
        '[AudioPlayerNotifier] currentTrack received: ${track?.title}',
      );
      state = state.copyWith(
        currentTrack: track,
        queue: service.trackQueue,
        currentTrackIndex: service.currentTrackIndex,
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
        queue: tracks,
        currentTrackIndex: startIndex,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Plays a single track.
  Future<void> playTrack(Track track) async {
    await playTracks([track], startIndex: 0);
  }

  /// Plays a track at a specific index in the queue.
  Future<void> playTrackAtIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    final service = _audioHandler as AudioPlayerService;
    await service.playTracks(state.queue, startIndex: index);
    state = state.copyWith(
      currentTrack: state.queue[index],
      currentTrackIndex: index,
    );
  }

  /// Pauses playback.
  Future<void> pause() async {
    debugPrint('[AudioPlayerNotifier] pause() called');
    await _audioHandler.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    debugPrint('[AudioPlayerNotifier] resume() called');
    await _audioHandler.play();
  }

  /// Toggles play/pause.
  Future<void> togglePlayPause() async {
    debugPrint(
      '[AudioPlayerNotifier] togglePlayPause() - current isPlaying: ${state.isPlaying}',
    );
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Seeks to a position.
  Future<void> seek(Duration position) async {
    debugPrint('[AudioPlayerNotifier] seek() called to position: $position');
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

  /// Sets the repeat mode.
  Future<void> setRepeatMode(PlayerRepeatMode mode) async {
    final service = _audioHandler as AudioPlayerService;
    RepeatMode repeatMode;
    switch (mode) {
      case PlayerRepeatMode.off:
        repeatMode = RepeatMode.off;
        break;
      case PlayerRepeatMode.all:
        repeatMode = RepeatMode.all;
        break;
      case PlayerRepeatMode.one:
        repeatMode = RepeatMode.one;
        break;
    }
    await service.setPlayerRepeatMode(repeatMode);
    state = state.copyWith(repeatMode: mode);
  }

  /// Cycles through repeat modes.
  Future<void> cycleRepeatMode() async {
    final currentMode = state.repeatMode;
    PlayerRepeatMode newMode;
    switch (currentMode) {
      case PlayerRepeatMode.off:
        newMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        newMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        newMode = PlayerRepeatMode.off;
        break;
    }
    await setRepeatMode(newMode);
  }

  /// Toggles shuffle mode.
  Future<void> toggleShuffle() async {
    final service = _audioHandler as AudioPlayerService;
    await service.toggleShuffle();
    state = state.copyWith(shuffleEnabled: service.isShuffleEnabled);
  }

  /// Reorders the queue.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final service = _audioHandler as AudioPlayerService;
    await service.reorderQueue(oldIndex, newIndex);
    state = state.copyWith(
      queue: service.trackQueue,
      currentTrackIndex: service.currentTrackIndex,
    );
  }

  /// Adds tracks to the queue.
  Future<void> addToQueue(List<Track> tracks) async {
    final service = _audioHandler as AudioPlayerService;
    await service.addToQueue(tracks);
    state = state.copyWith(queue: service.trackQueue);
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
