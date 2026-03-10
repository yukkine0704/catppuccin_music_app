import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/di/injection_container.dart';
import '../repositories/artwork_repository.dart';

/// Provider for ArtworkRepository.
final artworkRepositoryProvider = Provider<ArtworkRepository>((ref) {
  return getIt<ArtworkRepository>();
});

/// Cache for storing artwork bytes in memory.
/// Key: filePath (String), Value: artwork bytes
final _artworkCache = <String, Uint8List>{};

/// Cache for storing artwork with colors.
/// Key: 'colors_${filePath}_${flavor.mauve.value}', Value: AlbumArt with colors
final _artworkWithColorsCache = <String, AlbumArt>{};

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

  final repository = ref.watch(artworkRepositoryProvider);

  final result = await repository.getArtworkFromFile(filePath);

  return result.fold((failure) => null, (bytes) {
    if (bytes != null && bytes.isNotEmpty) {
        _artworkCache[filePath] = bytes;
    }
    return bytes;
  });
});

/// Provider for loading album artwork by albumId (legacy method using photo_manager).
/// Uses photo_manager to fetch artwork dynamically.
/// Note: Prefer using albumArtFromFileProvider with filePath when available.
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

/// Provider for loading album artwork and colors by filePath.
/// This is the main provider for the album accent feature.
///
/// Parameters:
/// - params: A tuple of (filePath, flavor) where filePath is the audio file path
///   and flavor is the Catppuccin flavor to use for color mapping
///
/// Returns:
/// - `AlbumArt` object containing bytes and extracted colors
final albumArtWithColorsProvider =
    FutureProvider.family<AlbumArt, (String?, Flavor)>((ref, params) async {
      final filePath = params.$1;
      final flavor = params.$2;

      if (filePath == null || filePath.isEmpty) {
        return const AlbumArt(bytes: null);
      }

      // Check cache first for albumArt with colors (includes flavor in key)
      final cacheKey = 'colors_${filePath}_${flavor.mauve.value}';
      if (_artworkWithColorsCache.containsKey(cacheKey)) {
        debugPrint(
          '[albumArtWithColorsProvider] Returning cached result for: $filePath',
        );
        return _artworkWithColorsCache[cacheKey]!;
      }

      final repository = ref.watch(artworkRepositoryProvider);

      // Use the repository method that computes colors based on flavor
      final result = await repository.getAlbumArtWithColors(filePath, flavor);

      return result.fold(
        (failure) {
          debugPrint('[albumArtWithColorsProvider] Error: $failure');
          return const AlbumArt(bytes: null);
        },
        (albumArt) {
        if (albumArt.bytes != null && albumArt.bytes!.isNotEmpty) {
          _artworkCache[filePath] = albumArt.bytes!;
        }
          // Cache the result with colors
          _artworkWithColorsCache[cacheKey] = albumArt;
          debugPrint(
            '[albumArtWithColorsProvider] Cached result with colors: dominant=${albumArt.dominantColor}, accent=${albumArt.accentColor}',
          );
        return albumArt;
      });
    });

/// Clears the artwork cache.
/// Useful when library is refreshed.
void clearArtworkCache() {
  _artworkCache.clear();
}
