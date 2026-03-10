import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Utility class to extract colors from album art.
class AlbumColorExtractor {
  /// Extracts the dominant color from album art bytes.
  static Future<Color?> extractDominantColor(Uint8List? imageBytes) async {
    if (imageBytes == null) {
      debugPrint('[AlbumColorExtractor] imageBytes is null, returning null');
      return null;
    }

    debugPrint(
      '[AlbumColorExtractor] Starting color extraction for ${imageBytes.length} bytes',
    );

    try {
      final imageProvider = MemoryImage(imageBytes);
      debugPrint(
        '[AlbumColorExtractor] Created MemoryImage, calling PaletteGenerator...',
      );

      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 16,
      );

      debugPrint('[AlbumColorExtractor] PaletteGenerator completed');
      debugPrint(
        '[AlbumColorExtractor] dominantColor: ${paletteGenerator.dominantColor?.color}',
      );
      debugPrint(
        '[AlbumColorExtractor] vibrantColor: ${paletteGenerator.vibrantColor?.color}',
      );
      debugPrint(
        '[AlbumColorExtractor] mutedColor: ${paletteGenerator.mutedColor?.color}',
      );
      debugPrint(
        '[AlbumColorExtractor] lightVibrantColor: ${paletteGenerator.lightVibrantColor?.color}',
      );
      debugPrint(
        '[AlbumColorExtractor] darkVibrantColor: ${paletteGenerator.darkVibrantColor?.color}',
      );
      debugPrint(
        '[AlbumColorExtractor] palette colors count: ${paletteGenerator.colors.length}',
      );

      // Try dominant color first, then vibrant, then Muted
      final color =
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          paletteGenerator.mutedColor?.color ??
          paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.darkVibrantColor?.color;

      if (color == null) {
        debugPrint(
          '[AlbumColorExtractor] No color found in palette, returning null',
        );
      } else {
        debugPrint('[AlbumColorExtractor] Found color: $color');
      }

      return color;
    } catch (e, stack) {
      debugPrint('[AlbumColorExtractor] ERROR extracting color: $e');
      debugPrint('[AlbumColorExtractor] Stack: $stack');
      return null;
    }
  }

  /// Checks if the color is colorful enough (not grayscale/low saturation).
  static bool isColorful(Color color) {
    final hsl = HSLColor.fromColor(color);
    // Saturation below 15% is considered grayscale
    // Lightness outside 15-85% is too dark or too bright
    return hsl.saturation > 0.15 &&
        hsl.lightness > 0.15 &&
        hsl.lightness < 0.85;
  }
}
