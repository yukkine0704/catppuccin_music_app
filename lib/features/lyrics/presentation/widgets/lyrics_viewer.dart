import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/providers/album_accent_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../domain/entities/lyric_line.dart';
import '../providers/lyrics_provider.dart';

/// Widget that displays synchronized lyrics with auto-scrolling.
///
/// Features:
/// - Auto-scrolls to current line based on playback position
/// - Highlights current line with different styling
/// - Tap to toggle visibility
/// - Smooth animations
class LyricsViewer extends ConsumerStatefulWidget {
  const LyricsViewer({super.key});

  @override
  ConsumerState<LyricsViewer> createState() => _LyricsViewerState();
}

class _LyricsViewerState extends ConsumerState<LyricsViewer> {
  final ScrollController _scrollController = ScrollController();
  int _lastScrolledIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final lyricsState = ref.watch(lyricsProvider);

    if (!lyricsState.isVisible) {
      return const SizedBox.shrink();
    }

    if (lyricsState.isLoading) {
      return _buildLoadingState(flavor);
    }

    if (!lyricsState.hasLyrics) {
      return _buildNoLyricsState(flavor);
    }

    return _buildLyricsList(flavor, lyricsState);
  }

  Widget _buildLoadingState(Flavor flavor) {
    return Container(
      color: flavor.base.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: flavor.mauve),
            const SizedBox(height: 16),
            Text('Loading lyrics...', style: TextStyle(color: flavor.subtext1)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLyricsState(Flavor flavor) {
    return Container(
      color: flavor.base.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lyrics_outlined, size: 64, color: flavor.subtext1),
            const SizedBox(height: 16),
            Text(
              'No lyrics available',
              style: TextStyle(color: flavor.subtext1, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Place a .lrc file next to the audio file',
              style: TextStyle(color: flavor.subtext0, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsList(Flavor flavor, LyricsState lyricsState) {
    // Get accent color for active line
    final accentState = ref.watch(albumAccentProvider);
    final accentColor = accentState.useAlbumColors || accentState.useGenreColors
        ? accentState.accentColor
        : flavor.mauve;

    // Auto-scroll to current line
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll(lyricsState.currentLineIndex);
    });

    return GestureDetector(
      onTap: () {
        ref.read(lyricsProvider.notifier).toggleVisibility();
      },
      child: Container(
        color: flavor.base.withValues(alpha: 0.95),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
          itemCount: lyricsState.lyrics.length,
          itemBuilder: (context, index) {
            return _buildLyricLine(
              flavor,
              accentColor,
              lyricsState.lyrics[index],
              index == lyricsState.currentLineIndex,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLyricLine(
    Flavor flavor,
    Color accentColor,
    LyricLine line,
    bool isActive,
    int index,
  ) {
    final isPastLine = index < ref.read(lyricsProvider).currentLineIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: isActive ? 22 : 18,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive
              ? accentColor
              : isPastLine
              ? flavor.subtext0
              : flavor.subtext1,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        child: Text(line.text, key: ValueKey('lyric_$index')),
      ),
    );
  }

  void _autoScroll(int currentIndex) {
    if (currentIndex < 0 || currentIndex == _lastScrolledIndex) {
      return;
    }

    _lastScrolledIndex = currentIndex;

    // Calculate position to scroll to (center of the screen)
    // Each item is approximately 60px (22px font + 16px padding * 2)
    const itemHeight = 60.0;
    final targetPosition =
        (currentIndex * itemHeight) -
        (MediaQuery.of(context).size.height / 2) +
        (itemHeight / 2);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

/// Compact lyrics overlay that shows current lyric line at the bottom.
class LyricsOverlay extends ConsumerWidget {
  const LyricsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final lyricsState = ref.watch(lyricsProvider);

    // Only show overlay if lyrics are visible and there's a current line
    if (!lyricsState.isVisible || !lyricsState.hasLyrics) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          ref.read(lyricsProvider.notifier).toggleVisibility();
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                flavor.base.withValues(alpha: 0.8),
                flavor.base,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: lyricsState.currentLineIndex >= 0
                ? Text(
                    lyricsState.currentLineText,
                    key: ValueKey(lyricsState.currentLineIndex),
                    style: TextStyle(
                      color: flavor.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
