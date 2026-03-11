import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/track.dart' as domain;

/// Resultado de la detección de cambios entre cache y escaneo
class ScanChanges {
  final List<domain.Track> added;
  final List<domain.Track> removed;
  final List<domain.Track> modified;

  const ScanChanges({
    required this.added,
    required this.removed,
    required this.modified,
  });

  bool get hasChanges =>
      added.isNotEmpty || removed.isNotEmpty || modified.isNotEmpty;
}

/// Datasource que combina el escaneo del sistema de archivos con cache en SQLite.
/// Implementa carga híbrida: cache primero, luego sync en background.
class LocalMusicDatabaseDatasource {
  final AppDatabase _database;

  LocalMusicDatabaseDatasource(this._database);

  /// Obtiene todos los tracks desde la base de datos (cache).
  /// Retorna lista vacía si no hay cache.
  Future<List<domain.Track>> getCachedTracks() async {
    final cachedTracks = await _database.getAllTracks();
    return cachedTracks.map(_mapToEntity).toList();
  }

  /// Obtiene el conteo de tracks en cache
  Future<int> getCachedTracksCount() => _database.getTracksCount();

  /// Verifica si existe cache
  Future<bool> hasCache() async {
    final count = await _database.getTracksCount();
    return count > 0;
  }

  /// Escanea el sistema de archivos y sincroniza con la base de datos.
  /// Retorna todos los tracks (del cache actualizado).
  ///
  /// [scannedTracks] son los tracks obtenidos del escaneo del sistema de archivos
  /// (usando el datasource original de photo_manager).
  Future<ScanChanges> syncWithDatabase(List<domain.Track> scannedTracks) async {
    // 1. Obtener tracks existentes en cache
    final cachedTracks = await _database.getAllTracks();
    final cachedByPath = {for (var t in cachedTracks) t.filePath: t};

    // 2. Crear mapa de tracks escaneados
    final scannedByPath = {for (var t in scannedTracks) t.filePath: t};

    final now = DateTime.now().millisecondsSinceEpoch;

    // 3. Detectar cambios
    final added = <domain.Track>[];
    final removed = <domain.Track>[];
    final modified = <domain.Track>[];

    // Pistas nuevas o modificadas
    for (final scanned in scannedTracks) {
      final cached = cachedByPath[scanned.filePath];
      if (cached == null) {
        // Nueva pista
        added.add(scanned);
      } else if (_hasMetadataChanged(scanned, cached)) {
        // Metadata cambiada
        modified.add(scanned);
      }
    }

    // Pistas eliminadas (están en cache pero no en escaneo)
    for (final cached in cachedTracks) {
      if (!scannedByPath.containsKey(cached.filePath)) {
        removed.add(_mapToEntity(cached));
      }
    }

    // 4. Aplicar cambios a la base de datos
    if (added.isNotEmpty) {
      final companions = added.map((t) => _mapToCompanion(t, now)).toList();
      await _database.insertTracks(companions);
    }

    if (modified.isNotEmpty) {
      for (final track in modified) {
        await _database.updateTrackByFilePath(
          track.filePath,
          _mapToCompanion(track, now),
        );
      }
    }

    if (removed.isNotEmpty) {
      final pathsToRemove = removed.map((t) => t.filePath).toList();
      await _database.deleteTracksByFilePaths(pathsToRemove);
    }

    return ScanChanges(added: added, removed: removed, modified: modified);
  }

  /// Fuerza un re-escaneo completo reemplanzando todo el cache
  Future<void> replaceCache(List<domain.Track> tracks) async {
    await _database.deleteAllTracks();

    if (tracks.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final companions = tracks.map((t) => _mapToCompanion(t, now)).toList();
    await _database.insertTracks(companions);
  }

  /// Busca tracks en el cache
  Future<List<domain.Track>> searchTracks(String query) async {
    final results = await _database.searchTracks(query);
    return results.map(_mapToEntity).toList();
  }

  // ============================================================
  // HELPERS PRIVADOS
  // ============================================================

  /// Convierte un registro de la base de datos a entidad del dominio
  domain.Track _mapToEntity(TracksTableData data) {
    return domain.Track(
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
    );
  }

  /// Convierte una entidad del dominio a companion para insertar/actualizar
  TracksTableCompanion _mapToCompanion(domain.Track track, int lastScanned) {
    return TracksTableCompanion(
      trackId: Value(track.id),
      title: Value(track.title),
      artist: Value(track.artist),
      album: Value(track.album),
      albumId: Value(track.albumId),
      filePath: Value(track.filePath),
      duration: Value(track.duration),
      trackNumber: Value(track.trackNumber),
      year: Value(track.year),
      dateAdded: Value(track.dateAdded),
      genre: Value(track.genre),
      lastScanned: Value(lastScanned),
    );
  }

  /// Compara si la metadata de un track escaneado es diferente del cache
  bool _hasMetadataChanged(domain.Track scanned, TracksTableData cached) {
    return scanned.title != cached.title ||
        scanned.artist != cached.artist ||
        scanned.album != cached.album ||
        scanned.albumId != cached.albumId ||
        scanned.trackNumber != cached.trackNumber ||
        scanned.year != cached.year ||
        scanned.genre != cached.genre;
  }
}
