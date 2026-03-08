import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../../library/domain/entities/track.dart';

/// Repeat mode for playback.
enum RepeatMode { off, all, one }

/// Audio player service that extends BaseAudioHandler for background playback.
class AudioPlayerService extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player;

  final List<Track> _tracks = [];
  int _currentIndex = 0;
  ConcatenatingAudioSource? _playlist;
  bool _shuffleEnabled = false;

  final _trackSubject = BehaviorSubject<Track?>.seeded(null);

  /// Current track stream.
  Stream<Track?> get currentTrackStream => _trackSubject.stream;

  /// Current playback state.
  @override
  BehaviorSubject<PlaybackState> get playbackState => _playbackState;
  final _playbackState = BehaviorSubject<PlaybackState>.seeded(PlaybackState());

  AudioPlayerService(this._player) {
    _init();
  }

  void _init() {
    // Broadcast player state changes
    _player.playbackEventStream.listen(_broadcastState);

    // Listen to current track index changes
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _tracks.length) {
        _currentIndex = index;
        _trackSubject.add(_tracks[index]);
        _updateMediaItem(_tracks[index]);
      }
    });
  }

  void _updateMediaItem(Track track) {
    mediaItem.add(
      MediaItem(
        id: track.id.toString(),
        title: track.title,
        artist: track.artist,
        album: track.album,
        duration: Duration(milliseconds: track.duration),
        artUri: track.albumArtPath != null
            ? Uri.file(track.albumArtPath!)
            : null,
      ),
    );
  }

  /// Plays a list of tracks starting from a specific index.
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;

    _tracks.clear();
    _tracks.addAll(tracks);
    _currentIndex = startIndex;

    // Set the audio source
    final audioSources = tracks.map((track) {
      return AudioSource.file(
        track.filePath,
        tag: MediaItem(
          id: track.id.toString(),
          title: track.title,
          artist: track.artist,
          album: track.album,
          duration: Duration(milliseconds: track.duration),
        ),
      );
    }).toList();

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: audioSources,
    );
    _playlist = playlist;

    await _player.setAudioSource(playlist, initialIndex: startIndex);
    _trackSubject.add(tracks[startIndex]);
    _updateMediaItem(tracks[startIndex]);

    await _player.play();
  }

  /// Plays a single track.
  Future<void> playTrack(Track track) async {
    await playTracks([track], startIndex: 0);
  }

  /// Pauses playback.
  @override
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _player.play();
  }

  /// Stops playback.
  @override
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seeks to a position.
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Skips to next track.
  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _tracks.length - 1) {
      await _player.seekToNext();
    }
  }

  /// Skips to previous track.
  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  /// Sets the playback speed.
  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Sets the repeat mode.
  Future<void> setPlayerRepeatMode(RepeatMode mode) async {
    switch (mode) {
      case RepeatMode.off:
        await _player.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
    }
  }

  /// Gets the current repeat mode.
  RepeatMode get repeatMode {
    switch (_player.loopMode) {
      case LoopMode.off:
        return RepeatMode.off;
      case LoopMode.all:
        return RepeatMode.all;
      case LoopMode.one:
        return RepeatMode.one;
    }
  }

  /// Toggles shuffle mode.
  Future<void> toggleShuffle() async {
    // Toggle internal shuffle state
    // Note: just_audio's ConcatenatingAudioSource doesn't have a direct shuffle method
    // Shuffle is handled by the player when shuffle mode is enabled
    _shuffleEnabled = !_shuffleEnabled;
    // Enable shuffle on the player
    await _player.setShuffleModeEnabled(_shuffleEnabled);
  }

  /// Gets the current shuffle mode.
  bool get isShuffleEnabled => _shuffleEnabled;

  /// Gets the current queue of tracks.
  List<Track> get trackQueue => List.unmodifiable(_tracks);

  /// Gets the current track index.
  int get currentTrackIndex => _currentIndex;

  /// Reorders the queue.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (_playlist != null) {
      await _playlist!.move(oldIndex, newIndex);
      // Update internal tracks list
      final track = _tracks.removeAt(oldIndex);
      _tracks.insert(newIndex, track);
      // Update current index if needed
      if (oldIndex == _currentIndex) {
        _currentIndex = newIndex;
      } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
        _currentIndex--;
      } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
        _currentIndex++;
      }
    }
  }

  /// Adds tracks to the queue.
  Future<void> addToQueue(List<Track> tracks) async {
    _tracks.addAll(tracks);
    if (_playlist != null) {
      final audioSources = tracks.map((track) {
        return AudioSource.file(
          track.filePath,
          tag: MediaItem(
            id: track.id.toString(),
            title: track.title,
            artist: track.artist,
            album: track.album,
            duration: Duration(milliseconds: track.duration),
          ),
        );
      }).toList();
      await _playlist!.addAll(audioSources);
    }
  }

  /// Gets the current position stream.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Gets the current buffered position stream.
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  /// Gets the duration of the current track.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Gets whether the player is playing.
  Stream<bool> get playingStream => _player.playingStream;

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    _playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex ?? 0,
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await _trackSubject.close();
    await _playbackState.close();
    await super.onTaskRemoved();
  }
}
