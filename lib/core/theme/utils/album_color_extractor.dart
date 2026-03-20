import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Result class containing all extracted palette colors.
class AlbumPaletteColors {
  final Color? dominantColor;
  final Color? vibrantColor;
  final Color? mutedColor;
  final Color? lightVibrantColor;
  final Color? darkVibrantColor;
  final Color? lightMutedColor;
  final Color? darkMutedColor;

  const AlbumPaletteColors({
    this.dominantColor,
    this.vibrantColor,
    this.mutedColor,
    this.lightVibrantColor,
    this.darkVibrantColor,
    this.lightMutedColor,
    this.darkMutedColor,
  });

  bool get hasAnyColor =>
      dominantColor != null ||
      vibrantColor != null ||
      mutedColor != null ||
      lightVibrantColor != null ||
      darkVibrantColor != null ||
      lightMutedColor != null ||
      darkMutedColor != null;

  /// Gets the best color for accent (prioritizes vibrant for more colorful look).
  Color? get accentColor =>
      vibrantColor ?? lightVibrantColor ?? darkVibrantColor ?? dominantColor;

  /// Gets the best color for subtle background gradients.
  Color? get backgroundColor =>
      mutedColor ?? lightMutedColor ?? darkMutedColor ?? dominantColor;
}

/// Utility class to extract colors from album art.
class AlbumColorExtractor {
  /// Extracts all palette colors from album art bytes.
  static Future<AlbumPaletteColors> extractAllColors(
    Uint8List? imageBytes,
  ) async {
    if (imageBytes == null) {
      debugPrint(
        '[AlbumColorExtractor] imageBytes is null, returning empty palette',
      );
      return const AlbumPaletteColors();
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

      return AlbumPaletteColors(
        dominantColor: paletteGenerator.dominantColor?.color,
        vibrantColor: paletteGenerator.vibrantColor?.color,
        mutedColor: paletteGenerator.mutedColor?.color,
        lightVibrantColor: paletteGenerator.lightVibrantColor?.color,
        darkVibrantColor: paletteGenerator.darkVibrantColor?.color,
        lightMutedColor: paletteGenerator.lightMutedColor?.color,
        darkMutedColor: paletteGenerator.darkMutedColor?.color,
      );
    } catch (e, stack) {
      debugPrint('[AlbumColorExtractor] ERROR extracting color: $e');
      debugPrint('[AlbumColorExtractor] Stack: $stack');
      return const AlbumPaletteColors();
    }
  }

  /// Extracts the dominant color from album art bytes.
  static Future<Color?> extractDominantColor(Uint8List? imageBytes) async {
    final palette = await extractAllColors(imageBytes);
    return palette.dominantColor ??
        palette.vibrantColor ??
        palette.mutedColor ??
        palette.lightVibrantColor ??
        palette.darkVibrantColor;
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
