import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/track.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/audio_player_provider.dart';

/// A bottom sheet widget that displays the current queue of tracks
/// with drag-and-drop reordering functionality.
class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  /// Shows the queue bottom sheet as a modal.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QueueBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);
    final queue = playerState.queue;
    final currentIndex = playerState.currentTrackIndex;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: flavor.base,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildHandle(flavor),
              _buildHeader(flavor, queue.length),
              Expanded(
                child: queue.isEmpty
                    ? _buildEmptyState(flavor)
                    : _buildQueueList(
                        context,
                        ref,
                        flavor,
                        queue,
                        currentIndex,
                        scrollController,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(Flavor flavor) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: flavor.subtext1,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(Flavor flavor, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Text(
            'Queue',
            style: TextStyle(
              color: flavor.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count tracks)',
            style: TextStyle(color: flavor.subtext1, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Flavor flavor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music_rounded, size: 64, color: flavor.subtext1),
          const SizedBox(height: 16),
          Text(
            'No tracks in queue',
            style: TextStyle(color: flavor.subtext1, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
    List<Track> queue,
    int currentIndex,
    ScrollController scrollController,
  ) {
    return ReorderableListView.builder(
      scrollController: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: queue.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        ref.read(audioPlayerProvider.notifier).reorderQueue(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final elevation = Tween<double>(
              begin: 0,
              end: 8,
            ).evaluate(animation);
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: flavor.mauve.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final track = queue[index];
        final isCurrentTrack = index == currentIndex;

        return _QueueTrackTile(
          key: ValueKey(track.id),
          track: track,
          flavor: flavor,
          isCurrentTrack: isCurrentTrack,
          index: index,
        );
      },
    );
  }
}

/// Individual track tile in the queue list.
class _QueueTrackTile extends StatelessWidget {
  final Track track;
  final Flavor flavor;
  final bool isCurrentTrack;
  final int index;

  const _QueueTrackTile({
    super.key,
    required this.track,
    required this.flavor,
    required this.isCurrentTrack,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentTrack ? flavor.surface1 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTrack
            ? Border.all(color: flavor.mauve.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildLeading(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
      ),
    );
  }

  Widget _buildLeading() {
    if (track.hasAlbumArt) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          track.albumArtBytes!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAlbumArt(),
        ),
      );
    }
    return _buildDefaultAlbumArt();
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: flavor.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.music_note_rounded, color: flavor.subtext1, size: 24),
    );
  }

  Widget _buildTitle() {
    return Text(
      track.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isCurrentTrack ? flavor.mauve : flavor.text,
        fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.normal,
        fontSize: 15,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      track.artist,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: flavor.subtext1, fontSize: 13),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCurrentTrack)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.equalizer_rounded, color: flavor.mauve, size: 20),
          ),
        Icon(Icons.drag_handle_rounded, color: flavor.subtext1, size: 20),
      ],
    );
  }
}
