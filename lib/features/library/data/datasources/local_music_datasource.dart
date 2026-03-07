import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/track.dart';

/// Data source for accessing local music files using on_audio_query.
class LocalMusicDatasource {
  final OnAudioQuery _audioQuery;

  LocalMusicDatasource(this._audioQuery);

  /// Requests storage permissions.
  Future<bool> requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    // Try audio permission for newer Android versions
    final audioStatus = await Permission.audio.request();
    return audioStatus.isGranted;
  }

  /// Fetches all songs from local storage.
  Future<List<Track>> getAllSongs() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs.map(_mapSongModelToTrack).toList();
  }

  /// Fetches songs by artist.
  Future<List<Track>> getSongsByArtist(String artist) async {
    final songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ARTIST,
      artist,
      sortType: SongSortType.TITLE,
    );

    return songs.map(_mapSongModelToTrack).toList();
  }

  /// Fetches songs by album.
  Future<List<Track>> getSongsByAlbum(String album) async {
    final songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM,
      album,
      sortType: SongSortType.TITLE,
    );

    return songs.map(_mapSongModelToTrack).toList();
  }

  /// Gets all albums.
  Future<List<dynamic>> getAllAlbums() async {
    return _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  /// Gets all artists.
  Future<List<dynamic>> getAllArtists() async {
    return _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  /// Gets artwork for a song.
  Future<dynamic> getArtwork(int id) async {
    return _audioQuery.queryArtwork(
      id,
      ArtworkType.AUDIO,
      format: ArtworkFormat.JPEG,
      size: 500,
    );
  }

  Track _mapSongModelToTrack(SongModel song) {
    return Track(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      filePath: song.data,
      duration: song.duration ?? 0,
      trackNumber: song.track,
    );
  }
}
