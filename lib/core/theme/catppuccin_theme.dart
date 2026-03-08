import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CatppuccinTheme creates a Material 3 ThemeData from Catppuccin flavors.
/// Maps Mocha flavor colors to Material 3 ColorScheme for M3E components.
class CatppuccinTheme {
  CatppuccinTheme._();

  /// Returns the Mocha flavor (dark theme) as a Material 3 ThemeData.
  static ThemeData get mochaTheme {
    final flavor = catppuccin.mocha;
    return _buildTheme(flavor);
  }

  /// Returns the Latte flavor (light theme) as a Material 3 ThemeData.
  static ThemeData get latteTheme {
    final flavor = catppuccin.latte;
    return _buildTheme(flavor);
  }

  /// Builds a complete ThemeData mapping Catppuccin colors to M3 fields.
  /// This is a private method used by the flavor-specific theme getters.
  static ThemeData _buildTheme(Flavor flavor) {
    final colorScheme = _buildColorScheme(flavor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: flavor.base,
      textTheme: _buildTextTheme(flavor),
      appBarTheme: AppBarTheme(
        backgroundColor: flavor.crust.withValues(alpha: 0.8),
        foregroundColor: flavor.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: flavor.text,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: flavor.mantle,
        selectedItemColor: flavor.mauve,
        unselectedItemColor: flavor.subtext1,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: flavor.mantle,
        indicatorColor: flavor.mauve.withValues(alpha: 0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: flavor.mauve);
          }
          return IconThemeData(color: flavor.subtext1);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: flavor.mauve,
            );
          }
          return GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: flavor.subtext1,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: flavor.surface0,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      iconTheme: IconThemeData(color: flavor.text, size: 24),
      sliderTheme: SliderThemeData(
        activeTrackColor: flavor.mauve,
        inactiveTrackColor: flavor.surface1,
        thumbColor: flavor.mauve,
        overlayColor: flavor.mauve.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: flavor.mauve,
        linearTrackColor: flavor.surface1,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: flavor.text,
        iconColor: flavor.subtext1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerTheme: DividerThemeData(color: flavor.surface0, thickness: 1),
      fontFamily: GoogleFonts.lexend().fontFamily,
    );
  }

  /// Public method to build a ThemeData from any Flavor.
  /// Use this when you need to dynamically switch between flavors.
  static ThemeData buildTheme(Flavor flavor) {
    return _buildTheme(flavor);
  }

  /// Maps Catppuccin colors to Material 3 ColorScheme fields.
  static ColorScheme _buildColorScheme(Flavor flavor) {
    // Determine brightness based on flavor - Latte is the only light theme
    final isLight = flavor == catppuccin.latte;
    final brightness = isLight ? Brightness.light : Brightness.dark;

    return ColorScheme(
      brightness: brightness,
      primary: flavor.mauve,
      onPrimary: flavor.crust,
      primaryContainer: flavor.mauve.withValues(alpha: 0.3),
      onPrimaryContainer: flavor.mauve,
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

  /// Builds the text theme using Lexend font.
  static TextTheme _buildTextTheme(Flavor flavor) {
    final base = GoogleFonts.lexend();

    return TextTheme(
      displayLarge: base.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: flavor.text,
      ),
      displayMedium: base.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: flavor.text,
      ),
      displaySmall: base.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: flavor.text,
      ),
      headlineLarge: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: flavor.text,
      ),
      headlineMedium: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: flavor.text,
      ),
      headlineSmall: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: flavor.text,
      ),
      titleLarge: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: flavor.text,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: flavor.text,
      ),
      titleSmall: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: flavor.text,
      ),
      bodyLarge: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: flavor.text,
      ),
      bodyMedium: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: flavor.text,
      ),
      bodySmall: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: flavor.subtext1,
      ),
      labelLarge: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: flavor.text,
      ),
      labelMedium: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: flavor.text,
      ),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: flavor.subtext1,
      ),
    );
  }
}

/// Extension to access Catppuccin colors easily throughout the app.
extension CatppuccinColors on BuildContext {
  /// Returns the current Catppuccin flavor from the theme.
  Flavor get flavor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? catppuccin.mocha : catppuccin.latte;
  }

  /// Quick access to Mauve (primary)
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Quick access to Surface (background)
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Quick access to Text color
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  /// Quick access to Secondary color
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
}
