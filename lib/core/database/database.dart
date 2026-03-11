import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/tracks_table.dart';

part 'database.g.dart';

/// Conexión principal de la base de datos de la aplicación.
/// Utiliza Drift para acceso type-safe a SQLite.
@DriftDatabase(tables: [TracksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor para testing con una conexión en memoria
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ============================================================
  // OPERACIONES CRUD PARA TRACKS
  // ============================================================

  /// Obtiene todos los tracks de la base de datos
  Future<List<TracksTableData>> getAllTracks() => select(tracksTable).get();

  /// Obtiene un track por su ID
  Future<TracksTableData?> getTrackById(int trackId) {
    return (select(
      tracksTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
  }

  /// Obtiene un track por su ruta de archivo
  Future<TracksTableData?> getTrackByFilePath(String filePath) {
    return (select(
      tracksTable,
    )..where((t) => t.filePath.equals(filePath))).getSingleOrNull();
  }

  /// Obtiene todos los filePaths de los tracks (para comparación)
  Future<List<String>> getAllFilePaths() async {
    final rows = await (select(tracksTable).map((t) => t.filePath)).get();
    return rows;
  }

  /// Inserta un nuevo track
  Future<int> insertTrack(TracksTableCompanion track) {
    return into(tracksTable).insert(track);
  }

  /// Inserta múltiples tracks a la vez
  Future<void> insertTracks(List<TracksTableCompanion> tracks) async {
    await batch((batch) {
      batch.insertAll(tracksTable, tracks);
    });
  }

  /// Actualiza un track existente
  Future<bool> updateTrack(TracksTableCompanion track) {
    return update(tracksTable).replace(track);
  }

  /// Actualiza un track por su filePath
  Future<int> updateTrackByFilePath(
    String filePath,
    TracksTableCompanion track,
  ) {
    return (update(
      tracksTable,
    )..where((t) => t.filePath.equals(filePath))).write(track);
  }

  /// Elimina un track por su ID
  Future<int> deleteTrack(int trackId) {
    return (delete(tracksTable)..where((t) => t.trackId.equals(trackId))).go();
  }

  /// Elimina un track por su filePath
  Future<int> deleteTrackByFilePath(String filePath) {
    return (delete(
      tracksTable,
    )..where((t) => t.filePath.equals(filePath))).go();
  }

  /// Elimina múltiples tracks por sus filePaths
  Future<int> deleteTracksByFilePaths(List<String> filePaths) {
    return (delete(tracksTable)..where((t) => t.filePath.isIn(filePaths))).go();
  }

  /// Elimina todos los tracks
  Future<int> deleteAllTracks() => delete(tracksTable).go();

  /// Obtiene el conteo de tracks
  Future<int> getTracksCount() async {
    final count = tracksTable.id.count();
    final query = selectOnly(tracksTable)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Busca tracks por título, artista o álbum
  Future<List<TracksTableData>> searchTracks(String query) {
    final searchPattern = '%$query%';
    return (select(tracksTable)..where(
          (t) =>
              t.title.like(searchPattern) |
              t.artist.like(searchPattern) |
              t.album.like(searchPattern),
        ))
        .get();
  }
}

/// Abre la conexión a la base de datos SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'catppuccin_music.db'));
    return NativeDatabase.createInBackground(file);
  });
}
