import '../../../library/domain/entities/track.dart';

/// Enum que define los tipos de smart playlists disponibles
enum SmartPlaylistType {
  recentlyAdded,
  mostPlayed,
}

/// Entidad que representa una Smart Playlist
class SmartPlaylist {
  final String id;
  final String name;
  final String description;
  final SmartPlaylistType type;
  final List<Track> tracks;
  final String iconName;

  const SmartPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tracks,
    required this.iconName,
  });

  /// Crea una copia con valores actualizados
  SmartPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    SmartPlaylistType? type,
    List<Track>? tracks,
    String? iconName,
  }) {
    return SmartPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      tracks: tracks ?? this.tracks,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPlaylist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
