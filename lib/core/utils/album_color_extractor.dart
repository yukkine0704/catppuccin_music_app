import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Utility class to extract colors from album art
class AlbumColorExtractor {
  /// Extracts the dominant color from album art bytes
  static Future<Color?> extractDominantColor(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;

    try {
      final imageProvider = MemoryImage(imageBytes);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 16,
      );

      // Try dominant color first, then vibrant, then Muted
      return paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          paletteGenerator.mutedColor?.color ??
          paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.darkVibrantColor?.color;
    } catch (e) {
      return null;
    }
  }

  /// Checks if the color is colorful enough (not grayscale/low saturation)
  static bool isColorful(Color color) {
    final hsl = HSLColor.fromColor(color);
    // Saturation below 15% is considered grayscale
    // Lightness outside 15-85% is too dark or too bright
    return hsl.saturation > 0.15 &&
        hsl.lightness > 0.15 &&
        hsl.lightness < 0.85;
  }
}
