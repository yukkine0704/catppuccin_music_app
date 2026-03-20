import '../../../../core/database/database.dart';
import '../../../library/domain/entities/track.dart';

/// DataSource para obtener datos de Smart Playlists desde la base de datos
class SmartPlaylistDataSource {
  final AppDatabase _database;

  SmartPlaylistDataSource(this._database);

  /// Obtiene las últimas canciones añadidas
  Future<List<Track>> getRecentlyAddedTracks({int limit = 20}) async {
    final tracks = await _database.getRecentlyAddedTracks(limit);
    return tracks.map(_mapToTrack).toList();
  }

  /// Obtiene las canciones más escuchadas
  Future<List<Track>> getMostPlayedTracks({int limit = 20}) async {
    final tracks = await _database.getMostPlayedTracks(limit);
    return tracks.map(_mapToTrack).toList();
  }

  /// Incrementa el contador de reproducciones de una pista
  Future<void> incrementPlayCount(int trackId) async {
    await _database.incrementPlayCount(trackId);
  }

  /// Convierte TracksTableData a Track
  Track _mapToTrack(TracksTableData data) {
    return Track(
      id: data.trackId,
      title: data.title,
      artist: data.artist,
      album: data.album,
      albumId: data.albumId,
      filePath: data.filePath,
      duration: data.duration,
      trackNumber: data.trackNumber,
      year: data.year,
      dateAdded: data.dateAdded,
      genre: data.genre,
      playCount: data.playCount,
    );
  }
}
