import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../library/domain/entities/track.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../domain/entities/smart_playlist.dart';
import '../providers/smart_playlists_provider.dart';

/// Pantalla principal de Smart Playlists
class SmartPlaylistsScreen extends ConsumerWidget {
  const SmartPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final playlistsState = ref.watch(smartPlaylistsNotifierProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBar(
        backgroundColor: flavor.base,
        elevation: 0,
        title: Text(
          'Playlists Inteligentes',
          style: TextStyle(color: flavor.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: flavor.text),
      ),
      body: playlistsState.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: flavor.mauve)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: flavor.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar playlists',
                style: TextStyle(color: flavor.text),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(smartPlaylistsNotifierProvider.notifier)
                      .loadAllPlaylists();
                },
                child: Text(
                  'Reintentar',
                  style: TextStyle(color: flavor.mauve),
                ),
              ),
            ],
          ),
        ),
        data: (playlists) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Colecciones dinámicas basadas en tu actividad',
              style: TextStyle(color: flavor.subtext0, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Recently Added Playlist
            _buildPlaylistSection(
              context,
              ref,
              flavor,
              SmartPlaylistType.recentlyAdded,
              'Agregadas Recientemente',
              'Últimas canciones añadidas a tu biblioteca',
              Icons.history_rounded,
              playlists[SmartPlaylistType.recentlyAdded] ?? [],
            ),

            const SizedBox(height: 16),

            // Most Played Playlist
            _buildPlaylistSection(
              context,
              ref,
              flavor,
              SmartPlaylistType.mostPlayed,
              'Más Escuchadas',
              'Tus canciones más reproducidas',
              Icons.trending_up_rounded,
              playlists[SmartPlaylistType.mostPlayed] ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistSection(
    BuildContext context,
    WidgetRef ref,
    dynamic flavor,
    SmartPlaylistType type,
    String title,
    String subtitle,
    IconData icon,
    List<Track> tracks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: flavor.mauve.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: flavor.mauve, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: flavor.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$subtitle • ${tracks.length} canciones',
                    style: TextStyle(color: flavor.subtext0, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tracks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: flavor.mantle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(icon, color: flavor.subtext1, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'No hay suficientes datos',
                    style: TextStyle(color: flavor.subtext0),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: flavor.mantle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tracks.length > 5 ? 5 : tracks.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: flavor.surface0),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return _TrackListTile(
                  track: track,
                  flavor: flavor,
                  onTap: () {
                    // Reproducir la playlist desde esta canción
                    ref
                        .read(audioPlayerProvider.notifier)
                        .playTracks(tracks, startIndex: index);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Individual track list tile
class _TrackListTile extends StatelessWidget {
  final Track track;
  final dynamic flavor;
  final VoidCallback onTap;

  const _TrackListTile({
    required this.track,
    required this.flavor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AlbumArtWidget(
        albumId: track.albumId,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(
        track.title,
        style: TextStyle(color: flavor.text, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: TextStyle(color: flavor.subtext0, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: track.playCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: flavor.mauve.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${track.playCount}',
                style: TextStyle(
                  color: flavor.mauve,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
