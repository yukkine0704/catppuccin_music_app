import 'dart:typed_data';

/// Immutable album entity representing a music album.
class Album {
  final String name;
  final String artist;
  final Uint8List? albumArtBytes;
  final String? albumArtPath;
  final int? year;
  final int trackCount;
  final DateTime? dateAdded;

  const Album({
    required this.name,
    required this.artist,
    this.albumArtBytes,
    this.albumArtPath,
    this.year,
    this.trackCount = 0,
    this.dateAdded,
  });

  /// Returns true if the album has cover art.
  bool get hasArt => albumArtBytes != null || albumArtPath != null;

  /// Creates a copy with optional new values.
  Album copyWith({
    String? name,
    String? artist,
    Uint8List? albumArtBytes,
    String? albumArtPath,
    int? year,
    int? trackCount,
    DateTime? dateAdded,
  }) {
    return Album(
      name: name ?? this.name,
      artist: artist ?? this.artist,
      albumArtBytes: albumArtBytes ?? this.albumArtBytes,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      year: year ?? this.year,
      trackCount: trackCount ?? this.trackCount,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Album &&
        other.name == name &&
        other.artist == artist;
  }

  @override
  int get hashCode => name.hashCode ^ artist.hashCode;
}
