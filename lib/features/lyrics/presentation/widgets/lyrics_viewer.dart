import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

import '../../../audio_player/presentation/providers/album_accent_provider.dart';
import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../domain/entities/lyric_line.dart';
import '../providers/lyrics_provider.dart';

/// Full-screen lyrics viewer displayed as a ModalBottomSheet.
///
/// Features:
/// - Auto-scrolls to current line based on playback position
/// - Tap on line to seek to that position
/// - Search online lyrics when no local lyrics found
/// - M3E compliant design with Catppuccin theme
/// - Accessibility support with Semantics
class LyricsViewer extends ConsumerWidget {
  const LyricsViewer({super.key});

  /// Shows the lyrics bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LyricsViewer(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final lyricsState = ref.watch(lyricsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: flavor.base,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: flavor.surface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // App Bar
              AppBarM3E(
                titleText: 'Letras',
                centerTitle: true,
                leading: IconButtonM3E(
                  variant: IconButtonM3EVariant.tonal,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: flavor.text,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
                actions: [
                  // Save/Delete lyrics button group
                  if (lyricsState.hasLyrics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ButtonGroupM3E(
                        type: ButtonGroupM3EType.connected,
                        shape: ButtonGroupM3EShape.round,
                        size: ButtonGroupM3ESize.sm,
                        selection: true,
                        style: ButtonM3EStyle.tonal,
                        actions: [
                          ButtonGroupM3EAction(
                            label: Icon(
                              Icons.save_alt_rounded,
                              size: 20,
                              color: !lyricsState.isSaved
                                  ? flavor.mauve
                                  : flavor.subtext1,
                            ),
                            selected: !lyricsState.isSaved,
                            onPressed: lyricsState.isSaved
                                ? null
                                : () async {
                                    // Save lyrics to file
                                    final saved = await ref
                                        .read(lyricsProvider.notifier)
                                        .saveLyricsToFile();
                                    if (saved && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Letras guardadas',
                                          ),
                                          backgroundColor: flavor.surface1,
                                        ),
                                      );
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Error al guardar letras',
                                          ),
                                          backgroundColor: flavor.surface1,
                                        ),
                                      );
                                    }
                                  },
                          ),
                          ButtonGroupM3EAction(
                            label: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: lyricsState.isSaved
                                  ? flavor.red
                                  : flavor.subtext1,
                            ),
                            selected: lyricsState.isSaved,
                            onPressed: lyricsState.isSaved
                                ? () async {
                                    // Delete saved lyrics
                                    final deleted = await ref
                                        .read(lyricsProvider.notifier)
                                        .deleteSavedLyrics();
                                    if (deleted && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Letras eliminadas',
                                          ),
                                          backgroundColor: flavor.surface1,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  if (lyricsState.canSearchOnline)
                    IconButtonM3E(
                      variant: IconButtonM3EVariant.tonal,
                      icon: Icon(Icons.search_rounded, color: flavor.text),
                      onPressed: () {
                        ref.read(lyricsProvider.notifier).searchOnlineLyrics();
                      },
                      tooltip: 'Buscar letras en línea',
                    ),
                  IconButtonM3E(
                    variant: IconButtonM3EVariant.tonal,
                    icon: Icon(Icons.close_rounded, color: flavor.text),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
                shapeFamily: AppBarM3EShapeFamily.round,
                density: AppBarM3EDensity.regular,
              ),
              // Content
              Expanded(
                child: _buildContent(
                  context,
                  ref,
                  flavor,
                  lyricsState,
                  scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
    LyricsState lyricsState,
    ScrollController scrollController,
  ) {
    if (lyricsState.isLoading || lyricsState.isSearchingOnline) {
      return _buildLoadingState(flavor, lyricsState.isSearchingOnline);
    }

    if (!lyricsState.hasLyrics) {
      return _buildNoLyricsState(context, ref, flavor, lyricsState);
    }

    return _buildLyricsList(
      context,
      ref,
      flavor,
      lyricsState,
      scrollController,
    );
  }

  Widget _buildLoadingState(Flavor flavor, bool isSearchingOnline) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicatorM3E(variant: LoadingIndicatorM3EVariant.contained),
          const SizedBox(height: 16),
          Text(
            isSearchingOnline
                ? 'Buscando letras en línea...'
                : 'Cargando letras...',
            style: TextStyle(color: flavor.subtext1, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLyricsState(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
    LyricsState lyricsState,
  ) {
    // Get current track info for default values
    final playerState = ref.watch(audioPlayerProvider);
    final currentTrack = playerState.currentTrack;
    final defaultArtist = currentTrack?.artist ?? '';
    final defaultTitle = currentTrack?.title ?? '';

    // Controllers for custom search fields
    final artistController = TextEditingController(text: defaultArtist);
    final titleController = TextEditingController(text: defaultTitle);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lyrics_outlined, size: 64, color: flavor.subtext1),
          const SizedBox(height: 16),
          Text(
            'No hay letras disponibles',
            style: TextStyle(
              color: flavor.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lyricsState.onlineSearchAttempted
                ? 'No se encontraron letras en LRCLIB\nPrueba buscar en Google'
                : 'Busca letras en la base de datos de LRCLIB\no coloca un archivo .lrc junto al audio',
            style: TextStyle(color: flavor.subtext1, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Custom search fields
          TextField(
            controller: artistController,
            decoration: InputDecoration(
              labelText: 'Artista',
              hintText: 'Nombre del artista',
              prefixIcon: Icon(Icons.person_outline, color: flavor.subtext1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: flavor.surface1,
            ),
            style: TextStyle(color: flavor.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Título',
              hintText: 'Título de la canción',
              prefixIcon: Icon(
                Icons.music_note_outlined,
                color: flavor.subtext1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: flavor.surface1,
            ),
            style: TextStyle(color: flavor.text),
          ),
          const SizedBox(height: 16),
          // Primary button: Search in LRCLIB database with custom query
          SizedBox(
            width: double.infinity,
            child: ButtonM3E(
              onPressed: lyricsState.isSearchingOnline
                  ? null
                  : () {
                      // Get the provider and call search with custom query
                      ref
                          .read(lyricsProvider.notifier)
                          .searchOnlineLyrics(
                            customArtist: artistController.text.trim(),
                            customTitle: titleController.text.trim(),
                          );
                    },
              label: Text(
                lyricsState.isSearchingOnline
                    ? 'Buscando en LRCLIB...'
                    : 'Buscar en LRCLIB',
              ),
              icon: lyricsState.isSearchingOnline
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_outlined),
              style: ButtonM3EStyle.filled,
              size: ButtonM3ESize.md,
            ),
          ),
          // Show Google search button only after LRCLIB search was attempted
          if (lyricsState.onlineSearchAttempted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ButtonM3E(
                onPressed: () {
                  // Use custom search terms for Google
                  final query =
                      '${artistController.text} ${titleController.text} lyrics';
                  _searchLyricsOnGoogleWithQuery(ref, query);
                },
                label: const Text('Buscar en Google'),
                icon: const Icon(Icons.language),
                style: ButtonM3EStyle.tonal,
                size: ButtonM3ESize.md,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLyricsList(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
    LyricsState lyricsState,
    ScrollController scrollController,
  ) {
    // Get accent color for active line
    final accentState = ref.watch(albumAccentProvider);
    final accentColor = accentState.useAlbumColors || accentState.useGenreColors
        ? accentState.accentColor
        : flavor.mauve;

    // Auto-scroll to current line
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll(
        scrollController,
        lyricsState.currentLineIndex,
        lyricsState.lyrics.length,
      );
    });

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      itemCount: lyricsState.lyrics.length,
      itemBuilder: (context, index) {
        return _buildLyricLine(
          context,
          ref,
          flavor,
          accentColor,
          lyricsState.lyrics[index],
          index == lyricsState.currentLineIndex,
          index,
          lyricsState.currentLineIndex,
        );
      },
    );
  }

  Widget _buildLyricLine(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
    Color accentColor,
    LyricLine line,
    bool isActive,
    int index,
    int currentIndex,
  ) {
    final isPastLine = index < currentIndex;

    return Semantics(
      label: 'Línea ${index + 1}: ${line.text}${isActive ? ", actual" : ""}',
      button: true,
      child: InkWell(
        onTap: () {
          ref.read(lyricsProvider.notifier).seekToLine(index);
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isActive ? 20 : 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? accentColor
                  : isPastLine
                  ? flavor.subtext0
                  : flavor.subtext1,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            child: Text(
              line.text.isEmpty ? '♪' : line.text,
              key: ValueKey('lyric_$index'),
            ),
          ),
        ),
      ),
    );
  }

  void _autoScroll(
    ScrollController controller,
    int currentIndex,
    int totalLines,
  ) {
    if (currentIndex < 0 || totalLines == 0) {
      return;
    }

    // Approximate height per line (20px font + 24px padding * 2)
    const itemHeight = 56.0;
    final targetPosition =
        (currentIndex * itemHeight) -
        (controller.position.viewportDimension / 2) +
        (itemHeight / 2);

    if (controller.hasClients) {
      controller.animateTo(
        targetPosition.clamp(0, controller.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _searchLyricsOnGoogle(WidgetRef ref) async {
    final playerState = ref.read(audioPlayerProvider);
    final currentTrack = playerState.currentTrack;

    if (currentTrack == null) {
      return;
    }

    final artist = currentTrack.artist;
    final title = currentTrack.title;

    if (artist.isEmpty && title.isEmpty) {
      return;
    }

    // Build search query with artist + title + lyrics
    final query = Uri.encodeComponent('$artist $title lyrics');
    final searchUrl = 'https://www.google.com/search?q=$query';

    // Show URL in debug console
    debugPrint('[LyricsViewer] Search URL: $searchUrl');
  }

  /// Search Google with a custom query string.
  Future<void> _searchLyricsOnGoogleWithQuery(
    WidgetRef ref,
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return;
    }

    final encodedQuery = Uri.encodeComponent(query.trim());
    final searchUrl = 'https://www.google.com/search?q=$encodedQuery';

    // Show URL in debug console
    debugPrint('[LyricsViewer] Search URL: $searchUrl');
  }
}

/// Compact lyrics overlay that shows current lyric line at the bottom.
/// Used in the mini player or as a quick preview.
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
          LyricsViewer.show(context);
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -300) {
            LyricsViewer.show(context);
          }
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
          child: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: lyricsState.currentLineIndex >= 0
                  ? Semantics(
                      label: 'Letra actual: ${lyricsState.currentLineText}',
                      child: Text(
                        lyricsState.currentLineText,
                        key: ValueKey(lyricsState.currentLineIndex),
                        style: TextStyle(
                          color: flavor.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
