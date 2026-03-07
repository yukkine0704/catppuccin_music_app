import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../domain/entities/track.dart';
import '../providers/library_provider.dart';

/// Library screen showing all local songs.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Load songs on init
    Future.microtask(() {
      ref.read(libraryProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final flavor = catppuccin.mocha;
    final libraryState = ref.watch(libraryProvider);
    final tracks = ref.watch(filteredTracksProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBarM3E(
        titleText: 'Biblioteca',
        backgroundColor: flavor.crust.withValues(alpha: 0.8),
        foregroundColor: flavor.text,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).refresh();
            },
            icon: Icon(Icons.refresh_rounded, color: flavor.text),
          ),
        ],
      ),
      body: _buildBody(context, libraryState, tracks, flavor),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LibraryState state,
    List<Track> tracks,
    Flavor flavor,
  ) {
    if (state.isLoading && tracks.isEmpty) {
      return const Center(
        child: LoadingIndicatorM3E(
          variant: LoadingIndicatorM3EVariant.contained, // default, contained
        ),
      );
    }

    if (state.error != null && tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: flavor.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar música',
              style: TextStyle(color: flavor.text, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(libraryProvider.notifier).loadSongs();
              },
              child: Text('Reintentar', style: TextStyle(color: flavor.mauve)),
            ),
          ],
        ),
      );
    }

    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off_rounded, size: 64, color: flavor.subtext1),
            const SizedBox(height: 16),
            Text(
              'No hay canciones',
              style: TextStyle(color: flavor.text, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade música a tu dispositivo',
              style: TextStyle(color: flavor.subtext1, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return _TrackListTile(track: track, flavor: flavor);
      },
    );
  }
}

/// Individual track list tile.
class _TrackListTile extends ConsumerWidget {
  final Track track;
  final Flavor flavor;

  const _TrackListTile({required this.track, required this.flavor});

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
          // Play the track
          final tracks = ref.read(filteredTracksProvider);
          final index = tracks.indexOf(track);
          ref
              .read(audioPlayerProvider.notifier)
              .playTracks(tracks, startIndex: index);
        },
      ),
      onTap: () {
        // Play the track
        final tracks = ref.read(filteredTracksProvider);
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
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : Image.asset(
                track.albumArtPath!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
