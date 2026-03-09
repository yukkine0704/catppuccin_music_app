import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/album_art_widget.dart';
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
          onTap: () {
            ref.read(audioPlayerProvider.notifier).playTrackAtIndex(index);
          },
        );
      },
    );
  }
}

/// Individual track tile in the queue list.
class _QueueTrackTile extends StatefulWidget {
  final Track track;
  final Flavor flavor;
  final bool isCurrentTrack;
  final int index;
  final VoidCallback onTap;

  const _QueueTrackTile({
    super.key,
    required this.track,
    required this.flavor,
    required this.isCurrentTrack,
    required this.index,
    required this.onTap,
  });

  @override
  State<_QueueTrackTile> createState() => _QueueTrackTileState();
}

class _QueueTrackTileState extends State<_QueueTrackTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isCurrentTrack) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _QueueTrackTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentTrack && !oldWidget.isCurrentTrack) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isCurrentTrack && oldWidget.isCurrentTrack) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.flavor.surface1.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: _buildLeading(),
              title: _buildTitle(),
              subtitle: _buildSubtitle(),
              trailing: _buildTrailing(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeading() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.isCurrentTrack
                ? [
                    BoxShadow(
                      color: widget.flavor.mauve.withValues(
                        alpha: widget.isCurrentTrack
                            ? _glowAnimation.value
                            : 0.0,
                      ),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: AlbumArtWidget(
        albumId: widget.track.albumId,
        size: 48,
        borderRadius: 8,
        flavor: widget.flavor,
      ),
    );
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.flavor.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.subtext1,
        size: 24,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.track.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: widget.isCurrentTrack ? widget.flavor.mauve : widget.flavor.text,
        fontWeight: widget.isCurrentTrack ? FontWeight.w600 : FontWeight.normal,
        fontSize: 15,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.track.artist,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: widget.flavor.subtext1, fontSize: 13),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isCurrentTrack)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: _AnimatedPlayingIndicator(),
          ),
        Icon(
          Icons.drag_handle_rounded,
          color: widget.flavor.subtext1,
          size: 20,
        ),
      ],
    );
  }
}

/// Animated playing indicator with equalizer bars.
class _AnimatedPlayingIndicator extends ConsumerStatefulWidget {
  const _AnimatedPlayingIndicator();

  @override
  ConsumerState<_AnimatedPlayingIndicator> createState() =>
      _AnimatedPlayingIndicatorState();
}

class _AnimatedPlayingIndicatorState
    extends ConsumerState<_AnimatedPlayingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start the animation loop
    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      for (final controller in _controllers) {
        controller.forward();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 200));
      for (final controller in _controllers) {
        controller.reverse();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 4,
                height: 20 * _animations[index].value,
                decoration: BoxDecoration(
                  color: flavor.mauve,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
