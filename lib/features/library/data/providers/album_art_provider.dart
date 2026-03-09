import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Cache for storing artwork bytes in memory.
/// Key: albumId (int), Value: artwork bytes
final _artworkCache = <int, Uint8List>{};

/// Provider for loading album artwork by albumId.
/// Uses photo_manager to fetch artwork dynamically.
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

  try {
    // Get all audio paths using static method
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
    );

    if (paths.isEmpty) {
      return null;
    }

    // Find the album matching the albumId
    // We use the hashCode of relativePath as albumId in local_music_datasource
    for (final path in paths) {
      final count = await path.assetCountAsync;
      if (count == 0) continue;

      final assets = await path.getAssetListPaged(page: 0, size: count);

      for (final asset in assets) {
        // Compare using the same logic as local_music_datasource
        final assetAlbumId = asset.relativePath?.hashCode;

        if (assetAlbumId == albumId) {
          // Get thumbnail for this asset
          final bytes = await asset.thumbnailDataWithSize(
            const ThumbnailSize(400, 400),
            quality: 100,
          );

          if (bytes != null && bytes.isNotEmpty) {
            // Store in cache
            _artworkCache[albumId] = bytes;
            return bytes;
          }
        }
      }
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
