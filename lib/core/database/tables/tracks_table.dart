import 'package:drift/drift.dart';

/// Tabla de Tracks para almacenar metadata de canciones en la base de datos.
/// Los datos se cachean para evitar re-escanear el sistema de archivos cada vez.
class TracksTable extends Table {
  /// ID único del registro en la base de datos
  IntColumn get id => integer().autoIncrement()();

  /// ID único de la pista en el sistema (del sistema de archivos)
  IntColumn get trackId => integer()();

  /// Título de la canción
  TextColumn get title => text()();

  /// Nombre del artista
  TextColumn get artist => text()();

  /// Nombre del álbum
  TextColumn get album => text()();

  /// ID del álbum (para cargar carátulas)
  IntColumn get albumId => integer().nullable()();

  /// Ruta absoluta al archivo de audio
  TextColumn get filePath => text().unique()();

  /// Duración en milisegundos
  IntColumn get duration => integer()();

  /// Número de pista en el álbum
  IntColumn get trackNumber => integer().nullable()();

  /// Año de lanzamiento
  IntColumn get year => integer().nullable()();

  /// Timestamp de cuándo se agregó al sistema
  IntColumn get dateAdded => integer().nullable()();

  /// Género musical
  TextColumn get genre => text().nullable()();

  /// Timestamp del último escaneo (para sync)
  IntColumn get lastScanned => integer()();
}
