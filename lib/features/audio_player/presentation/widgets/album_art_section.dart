import 'dart:typed_data';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../library/data/providers/album_art_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/player_animation_provider.dart';
import 'vinyl_animation.dart';

/// Album art section widget that displays either VinylAnimation or standard AlbumArtWidget
/// based on the selected animation style.
class AlbumArtSection extends ConsumerWidget {
  final PlayerState playerState;
  final PlayerAnimationStyle animationStyle;
  final double size;
  final double borderRadius;
  final Flavor flavor;

  const AlbumArtSection({
    super.key,
    required this.playerState,
    required this.animationStyle,
    required this.size,
    required this.borderRadius,
    required this.flavor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = playerState.isPlaying;

    // Watch album art provider for vinyl animation
    final filePath = playerState.currentTrack?.filePath;
    final albumArtAsync = filePath != null && filePath.isNotEmpty
        ? ref.watch(albumArtFromFileProvider(filePath))
        : const AsyncValue<Uint8List?>.data(null);

    if (animationStyle == PlayerAnimationStyle.vinyl) {
      return albumArtAsync.when(
        data: (albumArt) => VinylAnimation(
          albumArt: albumArt,
          flavor: flavor,
          size: size,
          isPlaying: isPlaying,
        ),
        loading: () => VinylAnimation(
          albumArt: null,
          flavor: flavor,
          size: size,
          isPlaying: isPlaying,
        ),
        error: (err, stack) => VinylAnimation(
          albumArt: null,
          flavor: flavor,
          size: size,
          isPlaying: isPlaying,
        ),
      );
    }

    return AlbumArtWidget(
      filePath: playerState.currentTrack?.filePath,
      albumId: playerState.currentTrack?.albumId,
      size: size,
      borderRadius: borderRadius,
      flavor: flavor,
    );
  }
}
