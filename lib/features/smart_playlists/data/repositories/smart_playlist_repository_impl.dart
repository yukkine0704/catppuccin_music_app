import '../../../library/domain/entities/track.dart';
import '../../domain/entities/smart_playlist.dart';
import '../datasources/smart_playlist_datasource.dart';

/// Repositorio para gestionar Smart Playlists
class SmartPlaylistRepository {
  final SmartPlaylistDataSource _dataSource;

  SmartPlaylistRepository(this._dataSource);

  /// Obtiene las playlist definidas
  List<SmartPlaylist> getPlaylists() {
    return [
      const SmartPlaylist(
        id: 'recently_added',
        name: 'Agregadas Recientemente',
        description: 'Últimas canciones añadidas a tu biblioteca',
        type: SmartPlaylistType.recentlyAdded,
        tracks: [],
        iconName: 'history',
      ),
      const SmartPlaylist(
        id: 'most_played',
        name: 'Más Escuchadas',
        description: 'Tus canciones más reproducidas',
        type: SmartPlaylistType.mostPlayed,
        tracks: [],
        iconName: 'trending_up',
      ),
    ];
  }

  /// Obtiene las canciones de una playlist específica
  Future<List<Track>> getTracksForPlaylist(SmartPlaylistType type, {int limit = 20}) async {
    switch (type) {
      case SmartPlaylistType.recentlyAdded:
        return _dataSource.getRecentlyAddedTracks(limit: limit);
      case SmartPlaylistType.mostPlayed:
        return _dataSource.getMostPlayedTracks(limit: limit);
    }
  }

  /// Incrementa el contador de reproducciones
  Future<void> incrementPlayCount(int trackId) async {
    await _dataSource.incrementPlayCount(trackId);
  }
}
