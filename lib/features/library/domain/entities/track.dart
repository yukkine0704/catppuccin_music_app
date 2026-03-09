

/// Entidad Track inmutable que representa una pista de música.
/// Actualizada para soportar el flujo de datos eficiente de MediaStore (on_audio_query).
class Track {
  final int id;
  final String title;
  final String artist;
  final String album;

  /// Identificador único del álbum en el sistema.
  /// Se usa para cargar la carátula de forma eficiente bajo demanda.
  final int? albumId;

  final String filePath;
  final int duration;
  final int? trackNumber;
  final int? year;
  final int?
  dateAdded; // Cambiado a int? para coincidir con el timestamp de MediaStore
  final String? genre;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId, // Nuevo campo clave
    required this.filePath,
    required this.duration,
    this.trackNumber,
    this.year,
    this.dateAdded,
    this.genre,
  });

  /// Determina si la canción tiene información de álbum para intentar cargar una carátula.
  bool get hasAlbumArt => albumId != null;

  /// Crea una copia con valores opcionales actualizados.
  Track copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    int? albumId,
    String? filePath,
    int? duration,
    int? trackNumber,
    int? year,
    int? dateAdded,
    String? genre,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      dateAdded: dateAdded ?? this.dateAdded,
      genre: genre ?? this.genre,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artist: $artist, albumId: $albumId)';
  }
}
