import 'package:equatable/equatable.dart';

/// Entidad que representa los metadatos editables de una pista de audio.
/// Se usa para el Editor de Etiquetas (Tag Editor).
class TagEdit extends Equatable {
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int? year;
  final int? trackNumber;
  final String? genre;
  final String? artworkPath;
  final int? albumId;

  const TagEdit({
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    this.year,
    this.trackNumber,
    this.genre,
    this.artworkPath,
    this.albumId,
  });

  /// Crea una copia con valores opcionales actualizados.
  TagEdit copyWith({
    String? filePath,
    String? title,
    String? artist,
    String? album,
    int? year,
    int? trackNumber,
    String? genre,
    String? artworkPath,
    int? albumId,
  }) {
    return TagEdit(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      genre: genre ?? this.genre,
      artworkPath: artworkPath ?? this.artworkPath,
      albumId: albumId ?? this.albumId,
    );
  }

  @override
  List<Object?> get props => [
        filePath,
        title,
        artist,
        album,
        year,
        trackNumber,
        genre,
        artworkPath,
        albumId,
      ];
}
