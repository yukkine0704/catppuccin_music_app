import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../providers/audio_player_provider.dart';

/// Music info row widget displaying title, artist, and favorite button.
class MusicInfoRow extends StatelessWidget {
  final PlayerState playerState;
  final Flavor flavor;
  final double animationValue;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle;

  const MusicInfoRow({
    super.key,
    required this.playerState,
    required this.flavor,
    required this.animationValue,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerState.currentTrack?.title ?? 'No hay canción',
                  style: TextStyle(
                    color: flavor.text,
                    fontSize: _lerp(14, 22, animationValue),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  playerState.currentTrack?.artist ?? 'Unknown Artist',
                  style: TextStyle(
                    color: flavor.subtext1,
                    fontSize: _lerp(12, 16, animationValue),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButtonM3E(
            variant: IconButtonM3EVariant.standard,
            size: IconButtonM3ESize.lg,
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? flavor.red : flavor.text,
            ),
            selectedIcon: Icon(Icons.favorite_rounded, color: flavor.red),
            isSelected: isFavorite,
            onPressed: () => onFavoriteToggle(!isFavorite),
            tooltip: 'Add to favorites',
          ),
        ],
      ),
    );
  }
}
