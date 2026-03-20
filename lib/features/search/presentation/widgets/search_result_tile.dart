import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../library/domain/entities/track.dart';

/// Widget for displaying a search result track tile.
class SearchResultTile extends ConsumerWidget {
  final Track track;
  final Flavor flavor;

  const SearchResultTile({
    super.key,
    required this.track,
    required this.flavor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: flavor.surface0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: AlbumArtWidget(
              filePath: track.filePath,
              albumId: track.albumId,
              size: 48,
            ),
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(color: flavor.text, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${track.artist} • ${track.album}',
          style: TextStyle(color: flavor.subtext1, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDuration(track.duration),
          style: TextStyle(color: flavor.subtext1, fontSize: 12),
        ),
        onTap: () {
          // Play the track directly
          ref.read(audioPlayerProvider.notifier).playTrack(track);
        },
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
