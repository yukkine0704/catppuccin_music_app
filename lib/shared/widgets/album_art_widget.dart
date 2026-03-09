import 'dart:typed_data';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/data/providers/album_art_provider.dart';

/// Reusable widget for displaying album artwork.
/// Uses AlbumArtProvider to load artwork by albumId.
/// Shows a placeholder when no artwork is available.
class AlbumArtWidget extends ConsumerWidget {
  /// The album ID to load artwork for.
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
    required this.albumId,
    this.size = 48,
    this.borderRadius = 8,
    this.placeholderIcon,
    this.flavor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use albumId - if null, return placeholder immediately
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
      error: (_, __) => _buildPlaceholder(),
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
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
