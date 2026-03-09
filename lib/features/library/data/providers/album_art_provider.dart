import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Provider for OnAudioQuery instance.
/// Created once and reused across the app.
final onAudioQueryProvider = Provider<OnAudioQuery>((ref) {
  return OnAudioQuery();
});

/// Cache for storing artwork bytes in memory.
/// Key: albumId, Value: artwork bytes
final _artworkCache = <int, Uint8List>{};

/// Provider for loading album artwork by albumId.
/// Uses on_audio_query to fetch artwork dynamically.
///
/// Returns:
/// - `null` if albumId is null or artwork not found
/// - `Uint8List` bytes of the artwork image
final albumArtProvider = FutureProvider.family<Uint8List?, int?>((ref, albumId) async {
  if (albumId == null) return null;

  // Check cache first
  if (_artworkCache.containsKey(albumId)) {
    return _artworkCache[albumId];
  }

  final audioQuery = ref.read(onAudioQueryProvider);

  try {
    // Query artwork for the album
    final artwork = await audioQuery.queryArtwork(
      albumId,
      ArtworkType.ALBUM,
      size: 400, // Size for good quality without excessive memory
      quality: 100,
    );

    if (artwork != null && artwork.isNotEmpty) {
      // Store in cache
      _artworkCache[albumId] = artwork;
      return artwork;
    }

    return null;
  } catch (e) {
    // Artwork not available for this album
    return null;
  }
});

/// Clears the artwork cache.
/// Useful when library is refreshed.
void clearArtworkCache() {
  _artworkCache.clear();
}
