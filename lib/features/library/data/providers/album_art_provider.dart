import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Cache for storing artwork bytes in memory.
/// Key: filePath (String) or albumId (int), Value: artwork bytes
final _artworkCache = <String, Uint8List>{};

/// Provider for loading album artwork by filePath using audio_metadata_reader.
/// This is the preferred method as it extracts embedded album art from the file.
///
/// Returns:
/// - `null` if filePath is null or artwork not found
/// - `Uint8List` bytes of the artwork image
final albumArtFromFileProvider = FutureProvider.family<Uint8List?, String?>((
  ref,
  filePath,
) async {
  if (filePath == null || filePath.isEmpty) return null;

  // Check cache first
  if (_artworkCache.containsKey(filePath)) {
    return _artworkCache[filePath];
  }

  try {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    // Extract metadata with image
    final metadata = readMetadata(file, getImage: true);

    // Get the first picture (usually the front cover)
    if (metadata.pictures.isNotEmpty) {
      final picture = metadata.pictures.first;
      final bytes = picture.bytes;

      if (bytes.isNotEmpty) {
        // Store in cache
        _artworkCache[filePath] = bytes;
        return bytes;
      }
    }

    return null;
  } catch (e) {
    // Artwork not available for this file
    return null;
  }
});

/// Provider for loading album artwork by albumId (legacy method using photo_manager).
/// Uses photo_manager to fetch artwork dynamically.
///
/// Returns:
/// - `null` if albumId is null or artwork not found
/// - `Uint8List` bytes of the artwork image
final albumArtProvider = FutureProvider.family<Uint8List?, int?>((ref, albumId) async {
  if (albumId == null) return null;

  // Convert int albumId to string for cache
  final cacheKey = 'albumId_$albumId';

  // Check cache first
  if (_artworkCache.containsKey(cacheKey)) {
    return _artworkCache[cacheKey];
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
            _artworkCache[cacheKey] = bytes;
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
