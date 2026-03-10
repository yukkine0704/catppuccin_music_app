import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/audio_player/presentation/providers/album_accent_provider.dart';
import '../../features/audio_player/presentation/providers/player_theme_provider.dart';
import '../../features/settings/presentation/providers/flavor_provider.dart';

/// A widget that wraps its child with a theme override based on album colors.
/// Use this to apply the album accent color to all M3E components in the subtree.
class AlbumThemeWrapper extends ConsumerWidget {
  final Widget child;

  const AlbumThemeWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final accentState = ref.watch(albumAccentProvider);
    final themeState = ref.watch(playerThemeProvider);

    // Determine if we should use album colors
    final useAlbumColors = themeState.isAlbumPaletteActive &&
        themeState.albumColorScheme != null;

    // Get the accent color
    final Color accentColor;
    if (useAlbumColors) {
      accentColor = themeState.currentAccentColor;
    } else if (accentState.useAlbumColors || accentState.useGenreColors) {
      accentColor = accentState.accentColor;
    } else {
      accentColor = flavor.mauve;
    }

    // Calculate contrast color for onPrimary
    final onPrimary =
        accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: accentColor,
              onPrimary: onPrimary,
              primaryContainer: accentColor.withValues(alpha: 0.3),
              onPrimaryContainer: accentColor,
            ),
      ),
      child: child,
    );
  }
}
