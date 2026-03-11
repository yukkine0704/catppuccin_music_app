import 'dart:typed_data';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/data/providers/album_art_provider.dart';

/// Reusable widget for displaying album artwork.
/// Supports two modes:
/// 1. filePath mode (preferred): Extracts embedded album art from the audio file
/// 2. albumId mode (legacy): Uses photo_manager to get artwork
///
/// Shows a placeholder when no artwork is available.
class AlbumArtWidget extends ConsumerWidget {
  /// The file path to extract artwork from (preferred method).
  final String? filePath;

  /// The album ID to load artwork for (legacy method).
  /// Used as fallback when filePath is not provided.
  final int? albumId;

  /// Size of the artwork.
  final double size;

  /// Border radius for the artwork.
  final double borderRadius;

  /// Optional custom placeholder icon.
  final IconData? placeholderIcon;

  /// Optional custom flavor (if not provided, uses default mocha).
  final Flavor? flavor;

  const AlbumArtWidget({
    super.key,
    this.filePath,
    this.albumId,
    this.size = 48,
    this.borderRadius = 8,
    this.placeholderIcon,
    this.flavor,
  }) : assert(
         filePath != null || albumId != null,
         'Either filePath or albumId must be provided',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer filePath if available (better quality from embedded art)
    if (filePath != null && filePath!.isNotEmpty) {
      final artworkAsync = ref.watch(albumArtFromFileProvider(filePath));

      return artworkAsync.when(
        data: (artworkBytes) {
          if (artworkBytes != null && artworkBytes.isNotEmpty) {
            return _buildArtwork(artworkBytes);
          }
          // Fallback to albumId if no embedded art found
          if (albumId != null) {
            return _buildFromAlbumId(ref, albumId);
          }
          return _buildPlaceholder();
        },
        loading: () => _buildLoading(),
        error: (_, _) {
          // Fallback to albumId on error
          if (albumId != null) {
            return _buildFromAlbumId(ref, albumId);
          }
          return _buildPlaceholder();
        },
      );
    }

    // Legacy mode: use albumId
    return _buildFromAlbumId(ref, albumId);
  }

  Widget _buildFromAlbumId(WidgetRef ref, int? albumId) {
    if (albumId == null) {
      return _buildPlaceholder();
    }

    final artworkAsync = ref.watch(albumArtProvider(albumId));

    return artworkAsync.when(
      data: (artworkBytes) {
        if (artworkBytes != null && artworkBytes.isNotEmpty) {
          return _buildArtwork(artworkBytes);
        }
        return _buildPlaceholder();
      },
      loading: () => _buildLoading(),
      error: (_, _) => _buildPlaceholder(),
    );
  }

  Widget _buildArtwork(Uint8List bytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final currentFlavor = flavor ?? catppuccin.mocha;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: currentFlavor.surface0,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        placeholderIcon ?? Icons.music_note,
        color: currentFlavor.subtext0,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildLoading() {
    final currentFlavor = flavor ?? catppuccin.mocha;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: currentFlavor.surface0,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: currentFlavor.subtext0,
          ),
        ),
      ),
    );
  }
}

/// Provider for the default Catppuccin flavor.
/// Returns mocha by default - can be overridden with actual flavor.
final defaultFlavorProvider = Provider<Flavor>((ref) {
  return catppuccin.mocha;
});
