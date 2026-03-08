import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../audio_player/presentation/providers/history_provider.dart';
import '../../../library/domain/entities/track.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';

/// Most played screen showing most frequently played tracks.
class MostPlayedScreen extends ConsumerWidget {
  const MostPlayedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final mostPlayed = ref.watch(mostPlayedProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBarM3E(
        titleText: 'Más reproducidas',
        backgroundColor: flavor.crust.withValues(alpha: 0.8),
        foregroundColor: flavor.text,
        actions: [
          if (mostPlayed.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: flavor.text),
              onPressed: () {
                ref.read(historyProvider.notifier).clearMostPlayed();
              },
              tooltip: 'Limpiar',
            ),
        ],
      ),
      body: mostPlayed.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 64,
                    color: flavor.subtext1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin datos',
                    style: TextStyle(color: flavor.text, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las canciones que reproduzcas aparecerán aquí',
                    style: TextStyle(color: flavor.subtext1, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: mostPlayed.length,
              itemBuilder: (context, index) {
                final track = mostPlayed[index];
                return _MostPlayedTrackTile(track: track, flavor: flavor);
              },
            ),
    );
  }
}

/// Track list tile for most played screen.
class _MostPlayedTrackTile extends ConsumerWidget {
  final Track track;
  final Flavor flavor;

  const _MostPlayedTrackTile({required this.track, required this.flavor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _buildAlbumArt(),
      title: Text(
        track.title,
        style: TextStyle(color: flavor.text, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: TextStyle(color: flavor.subtext1),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.play_circle_fill_rounded,
          color: flavor.mauve,
          size: 32,
        ),
        onPressed: () {
          final tracks = ref.read(mostPlayedProvider);
          final index = tracks.indexOf(track);
          ref
              .read(audioPlayerProvider.notifier)
              .playTracks(tracks, startIndex: index);
        },
      ),
      onTap: () {
        final tracks = ref.read(mostPlayedProvider);
        final index = tracks.indexOf(track);
        ref
            .read(audioPlayerProvider.notifier)
            .playTracks(tracks, startIndex: index);
      },
    );
  }

  Widget _buildAlbumArt() {
    if (track.hasAlbumArt) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: track.albumArtBytes != null
            ? Image.memory(
                track.albumArtBytes!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildPlaceholder(),
              )
            : Image.asset(
                track.albumArtPath!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildPlaceholder(),
              ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: flavor.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.music_note_rounded, color: flavor.subtext1),
    );
  }
}
