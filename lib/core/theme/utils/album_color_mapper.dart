import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

/// Maps extracted album colors to closest Catppuccin accent.
class AlbumColorMapper {
  /// Maps genre to Catppuccin accent color (English & Spanish).
  /// Used as fallback when no album art is available.
  /// Note: Using mocha colors as reference, mapped to current flavor at runtime.
  static final Map<String, Color> genreColorMap = {
    // English genres
    'rock': catppuccin.mocha.red,
    'pop': catppuccin.mocha.pink,
    'electronic': catppuccin.mocha.teal,
    'edm': catppuccin.mocha.sky,
    'hiphop': catppuccin.mocha.maroon,
    'rap': catppuccin.mocha.maroon,
    'jazz': catppuccin.mocha.peach,
    'classical': catppuccin.mocha.lavender,
    'metal': catppuccin.mocha.surface2,
    'country': catppuccin.mocha.yellow,
    'rb': catppuccin.mocha.pink,
    'rnb': catppuccin.mocha.pink,
    'soul': catppuccin.mocha.maroon,
    'reggae': catppuccin.mocha.green,
    'latin': catppuccin.mocha.peach,
    'indie': catppuccin.mocha.mauve,
    'ambient': catppuccin.mocha.sapphire,
    'techno': catppuccin.mocha.blue,
    'dance': catppuccin.mocha.mauve,
    'punk': catppuccin.mocha.red,
    'blues': catppuccin.mocha.blue,
    'folk': catppuccin.mocha.yellow,
    'disco': catppuccin.mocha.pink,
    'house': catppuccin.mocha.teal,
    'trap': catppuccin.mocha.maroon,
    // Spanish genres / Géneros en español
    'electrónica': catppuccin.mocha.teal,
    'clásica': catppuccin.mocha.lavender,
    'salsa': catppuccin.mocha.red,
    'merengue': catppuccin.mocha.yellow,
    'bachata': catppuccin.mocha.maroon,
    'cumbia': catppuccin.mocha.green,
    'tango': catppuccin.mocha.red,
    'flamenco': catppuccin.mocha.red,
    'folklore': catppuccin.mocha.yellow,
    'latino': catppuccin.mocha.peach,
  };

  /// Gets accent color based on genre.
  static Color getGenreAccent(String? genre, Flavor flavor) {
    if (genre == null || genre.isEmpty) {
      return flavor.mauve; // Default
    }

    // Normalize genre to lowercase for matching
    final normalizedGenre = genre.toLowerCase().trim();

    // Direct match
    if (genreColorMap.containsKey(normalizedGenre)) {
      // Map to current flavor's colors
      return _mapToFlavor(genreColorMap[normalizedGenre]!, flavor);
    }

    // Partial match (contains) - check for common genre substrings
    final genreLower = normalizedGenre.toLowerCase();

    if (genreLower.contains('rock')) {
      return _mapToFlavor(catppuccin.mocha.red, flavor);
    } else if (genreLower.contains('pop')) {
      return _mapToFlavor(catppuccin.mocha.pink, flavor);
    } else if (genreLower.contains('electronic') ||
        genreLower.contains('edm') ||
        genreLower.contains('techno') ||
        genreLower.contains('house')) {
      return _mapToFlavor(catppuccin.mocha.teal, flavor);
    } else if (genreLower.contains('hip') && genreLower.contains('hop') ||
        genreLower.contains('rap') ||
        genreLower.contains('trap')) {
      return _mapToFlavor(catppuccin.mocha.maroon, flavor);
    } else if (genreLower.contains('jazz')) {
      return _mapToFlavor(catppuccin.mocha.peach, flavor);
    } else if (genreLower.contains('classical') ||
        genreLower.contains('clásica')) {
      return _mapToFlavor(catppuccin.mocha.lavender, flavor);
    } else if (genreLower.contains('metal')) {
      return _mapToFlavor(catppuccin.mocha.surface2, flavor);
    } else if (genreLower.contains('country') || genreLower.contains('folk')) {
      return _mapToFlavor(catppuccin.mocha.yellow, flavor);
    } else if (genreLower.contains('r&b') ||
        genreLower.contains('rnb') ||
        genreLower.contains('soul')) {
      return _mapToFlavor(catppuccin.mocha.pink, flavor);
    } else if (genreLower.contains('reggae')) {
      return _mapToFlavor(catppuccin.mocha.green, flavor);
    } else if (genreLower.contains('latin') ||
        genreLower.contains('latino') ||
        genreLower.contains('salsa') ||
        genreLower.contains('cumbia')) {
      return _mapToFlavor(catppuccin.mocha.peach, flavor);
    } else if (genreLower.contains('indie')) {
      return _mapToFlavor(catppuccin.mocha.mauve, flavor);
    } else if (genreLower.contains('ambient')) {
      return _mapToFlavor(catppuccin.mocha.sapphire, flavor);
    } else if (genreLower.contains('dance') || genreLower.contains('disco')) {
      return _mapToFlavor(catppuccin.mocha.mauve, flavor);
    } else if (genreLower.contains('punk')) {
      return _mapToFlavor(catppuccin.mocha.red, flavor);
    } else if (genreLower.contains('blues') || genreLower.contains('blue')) {
      return _mapToFlavor(catppuccin.mocha.blue, flavor);
    } else if (genreLower.contains('flamenco') ||
        genreLower.contains('tango')) {
      return _mapToFlavor(catppuccin.mocha.red, flavor);
    } else if (genreLower.contains('merengue')) {
      return _mapToFlavor(catppuccin.mocha.yellow, flavor);
    } else if (genreLower.contains('bachata')) {
      return _mapToFlavor(catppuccin.mocha.maroon, flavor);
    }

    return flavor.mauve; // Default
  }

  /// Maps a color from mocha to the current flavor's equivalent.
  static Color _mapToFlavor(Color mochaColor, Flavor flavor) {
    // Find which accent this is in mocha
    final mochaAccents = {
      catppuccin.mocha.mauve: 'mauve',
      catppuccin.mocha.pink: 'pink',
      catppuccin.mocha.red: 'red',
      catppuccin.mocha.maroon: 'maroon',
      catppuccin.mocha.peach: 'peach',
      catppuccin.mocha.yellow: 'yellow',
      catppuccin.mocha.green: 'green',
      catppuccin.mocha.teal: 'teal',
      catppuccin.mocha.sky: 'sky',
      catppuccin.mocha.sapphire: 'sapphire',
      catppuccin.mocha.blue: 'blue',
      catppuccin.mocha.lavender: 'lavender',
    };

    final accentName = mochaAccents[mochaColor];
    if (accentName == null) return flavor.mauve;

    // Get the equivalent from current flavor
    switch (accentName) {
      case 'mauve':
        return flavor.mauve;
      case 'pink':
        return flavor.pink;
      case 'red':
        return flavor.red;
      case 'maroon':
        return flavor.maroon;
      case 'peach':
        return flavor.peach;
      case 'yellow':
        return flavor.yellow;
      case 'green':
        return flavor.green;
      case 'teal':
        return flavor.teal;
      case 'sky':
        return flavor.sky;
      case 'sapphire':
        return flavor.sapphire;
      case 'blue':
        return flavor.blue;
      case 'lavender':
        return flavor.lavender;
      default:
        return flavor.mauve;
    }
  }

  /// Finds the closest Catppuccin accent color to the given color.
  static Color findClosestAccent(Color color, Flavor flavor) {
    // Get accent colors for the current flavor
    final flavorAccents = _getFlavorAccents(flavor);

    double minDistance = double.infinity;
    Color closest = flavor.mauve; // Default

    for (final accent in flavorAccents) {
      final distance = _colorDistance(color, accent);
      if (distance < minDistance) {
        minDistance = distance;
        closest = accent;
      }
    }

    return closest;
  }

  /// Gets accent colors for a specific flavor.
  static List<Color> _getFlavorAccents(Flavor flavor) {
    return [
      flavor.mauve,
      flavor.pink,
      flavor.red,
      flavor.maroon,
      flavor.peach,
      flavor.yellow,
      flavor.green,
      flavor.teal,
      flavor.sky,
      flavor.sapphire,
      flavor.blue,
      flavor.lavender,
    ];
  }

  /// Calculates Euclidean distance between two colors in RGB space.
  static double _colorDistance(Color a, Color b) {
    final dr = (a.r * 255).round() - (b.r * 255).round();
    final dg = (a.g * 255).round() - (b.g * 255).round();
    final db = (a.b * 255).round() - (b.b * 255).round();
    return (dr * dr + dg * dg + db * db).toDouble();
  }
}
