import 'dart:typed_data';

/// Immutable track entity representing a music track.
class Track {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? albumArtPath;
  final Uint8List? albumArtBytes;
  final String filePath;
  final int duration;
  final int? trackNumber;
  final int? year;
  final DateTime? dateAdded;
  final String? genre;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtPath,
    this.albumArtBytes,
    required this.filePath,
    required this.duration,
    this.trackNumber,
    this.year,
    this.dateAdded,
    this.genre,
  });

  /// Returns true if the track has embedded album art.
  bool get hasAlbumArt => albumArtBytes != null || albumArtPath != null;

  /// Creates a copy with optional new values.
  Track copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    Uint8List? albumArtBytes,
    String? filePath,
    int? duration,
    int? trackNumber,
    int? year,
    DateTime? dateAdded,
    String? genre,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      albumArtBytes: albumArtBytes ?? this.albumArtBytes,
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
}
