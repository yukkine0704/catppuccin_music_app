import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

/// Maps extracted album colors to the closest Catppuccin color.
/// Uses HSL distance calculation for accurate color matching.
class AlbumPaletteGenerator {
  AlbumPaletteGenerator._();

  /// Accent colors available in Catppuccin for matching.
  /// These are the vibrant colors used for primary accents.
  static const List<CatppuccinColor> _accentColors = [
    CatppuccinColor.rosewater,
    CatppuccinColor.flamenco,
    CatppuccinColor.pink,
    CatppuccinColor.mauve,
    CatppuccinColor.red,
    CatppuccinColor.maroon,
    CatppuccinColor.peach,
    CatppuccinColor.yellow,
    CatppuccinColor.green,
    CatppuccinColor.teal,
    CatppuccinColor.sky,
    CatppuccinColor.sapphire,
    CatppuccinColor.blue,
    CatppuccinColor.lavender,
  ];

  /// Finds the closest Catppuccin color to the given album color.
  /// Returns a record with the closest color and its name.
  static ClosestColorResult findClosestColor(Color albumColor, Flavor flavor) {
    double minDistance = double.infinity;
    CatppuccinColor closestColorName = CatppuccinColor.mauve;
    Color closestColor = flavor.mauve;

    for (final colorName in _accentColors) {
      final catppuccinColor = _getColorFromFlavor(flavor, colorName);
      final distance = _calculateColorDistance(albumColor, catppuccinColor);

      if (distance < minDistance) {
        minDistance = distance;
        closestColorName = colorName;
        closestColor = catppuccinColor;
      }
    }

    return ClosestColorResult(
      color: closestColor,
      colorName: closestColorName,
      distance: minDistance,
    );
  }

  /// Gets the actual Color from Flavor based on CatppuccinColor enum.
  static Color _getColorFromFlavor(Flavor flavor, CatppuccinColor colorName) {
    switch (colorName) {
      case CatppuccinColor.rosewater:
        return flavor.rosewater;
      case CatppuccinColor.flamenco:
        return flavor.flamingo;
      case CatppuccinColor.pink:
        return flavor.pink;
      case CatppuccinColor.mauve:
        return flavor.mauve;
      case CatppuccinColor.red:
        return flavor.red;
      case CatppuccinColor.maroon:
        return flavor.maroon;
      case CatppuccinColor.peach:
        return flavor.peach;
      case CatppuccinColor.yellow:
        return flavor.yellow;
      case CatppuccinColor.green:
        return flavor.green;
      case CatppuccinColor.teal:
        return flavor.teal;
      case CatppuccinColor.sky:
        return flavor.sky;
      case CatppuccinColor.sapphire:
        return flavor.sapphire;
      case CatppuccinColor.blue:
        return flavor.blue;
      case CatppuccinColor.lavender:
        return flavor.lavender;
    }
  }

  /// Calculates distance between two colors in HSL space.
  /// Uses weighted distance: hue (50%), saturation (30%), lightness (20%)
  static double _calculateColorDistance(Color a, Color b) {
    final hslA = HSLColor.fromColor(a);
    final hslB = HSLColor.fromColor(b);

    // Hue distance (circular)
    double hueDiff = (hslA.hue - hslB.hue).abs();
    if (hueDiff > 180) {
      hueDiff = 360 - hueDiff;
    }

    // Saturation and lightness differences
    final satDiff = (hslA.saturation - hslB.saturation).abs();
    final lightDiff = (hslA.lightness - hslB.lightness).abs();

    // Weighted distance: hue is most important for similar colors
    return (hueDiff * 0.5) + (satDiff * 0.3) + (lightDiff * 0.2);
  }

  /// Builds a ColorScheme with the accent color replacing primary.
  /// Uses the existing CatppuccinTheme logic but with custom accent.
  static ColorScheme buildColorSchemeWithAccent(
    Flavor flavor,
    Color accentColor,
  ) {
    final isLight = flavor == catppuccin.latte;
    final brightness = isLight ? Brightness.light : Brightness.dark;
    final onAccent = _getContrastColor(accentColor);

    return ColorScheme(
      brightness: brightness,
      primary: accentColor,
      onPrimary: onAccent,
      primaryContainer: accentColor.withValues(alpha: 0.3),
      onPrimaryContainer: accentColor,
      secondary: flavor.pink,
      onSecondary: flavor.crust,
      secondaryContainer: flavor.pink.withValues(alpha: 0.3),
      onSecondaryContainer: flavor.pink,
      tertiary: flavor.blue,
      onTertiary: flavor.crust,
      tertiaryContainer: flavor.blue.withValues(alpha: 0.3),
      onTertiaryContainer: flavor.blue,
      error: flavor.red,
      onError: flavor.crust,
      errorContainer: flavor.red.withValues(alpha: 0.3),
      onErrorContainer: flavor.red,
      surface: flavor.base,
      onSurface: flavor.text,
      surfaceContainerHighest: flavor.surface1,
      onSurfaceVariant: flavor.subtext1,
      outline: flavor.surface2,
      outlineVariant: flavor.surface0,
      shadow: flavor.crust,
      scrim: flavor.mantle,
      inverseSurface: flavor.text,
      onInverseSurface: flavor.base,
      inversePrimary: flavor.blue,
    );
  }

  /// Gets a contrasting color (black or white) for text on the given background.
  static Color _getContrastColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Builds a complete ThemeData with the accent color.
  /// This combines CatppuccinTheme with custom accent.
  static ThemeData buildThemeWithAccent(Flavor flavor, Color accentColor) {
    final colorScheme = buildColorSchemeWithAccent(flavor, accentColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: flavor.base,
      // Other theme properties can be added here
      // They will use the flavor's base colors
    );
  }
}

/// Enum representing Catppuccin accent colors for matching.
enum CatppuccinColor {
  rosewater,
  flamenco,
  pink,
  mauve,
  red,
  maroon,
  peach,
  yellow,
  green,
  teal,
  sky,
  sapphire,
  blue,
  lavender,
}

/// Result of finding the closest Catppuccin color.
class ClosestColorResult {
  final Color color;
  final CatppuccinColor colorName;
  final double distance;

  const ClosestColorResult({
    required this.color,
    required this.colorName,
    required this.distance,
  });

  /// Returns the name of the color as a string.
  String get colorNameString {
    switch (colorName) {
      case CatppuccinColor.rosewater:
        return 'Rosewater';
      case CatppuccinColor.flamenco:
        return 'Flamingo';
      case CatppuccinColor.pink:
        return 'Pink';
      case CatppuccinColor.mauve:
        return 'Mauve';
      case CatppuccinColor.red:
        return 'Red';
      case CatppuccinColor.maroon:
        return 'Maroon';
      case CatppuccinColor.peach:
        return 'Peach';
      case CatppuccinColor.yellow:
        return 'Yellow';
      case CatppuccinColor.green:
        return 'Green';
      case CatppuccinColor.teal:
        return 'Teal';
      case CatppuccinColor.sky:
        return 'Sky';
      case CatppuccinColor.sapphire:
        return 'Sapphire';
      case CatppuccinColor.blue:
        return 'Blue';
      case CatppuccinColor.lavender:
        return 'Lavender';
    }
  }
}
