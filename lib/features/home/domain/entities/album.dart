

/// Immutable album entity representing a music album.
/// Updated to use albumId for loading artwork on-demand.
class Album {
  final String name;
  final String artist;

  /// Album ID for loading artwork on-demand via AlbumArtProvider.
  final int? albumId;

  final int? year;
  final int trackCount;
  final DateTime? dateAdded;

  const Album({
    required this.name,
    required this.artist,
    this.albumId,
    this.year,
    this.trackCount = 0,
    this.dateAdded,
  });

  /// Returns true if the album has an album ID for artwork loading.
  bool get hasArt => albumId != null;

  /// Creates a copy with optional new values.
  Album copyWith({
    String? name,
    String? artist,
    int? albumId,
    int? year,
    int? trackCount,
    DateTime? dateAdded,
  }) {
    return Album(
      name: name ?? this.name,
      artist: artist ?? this.artist,
      albumId: albumId ?? this.albumId,
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

  @override
  String toString() {
    return 'Album(name: $name, artist: $artist, albumId: $albumId)';
  }
}
