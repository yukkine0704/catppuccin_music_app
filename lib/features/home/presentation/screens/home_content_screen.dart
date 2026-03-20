import 'dart:async';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../../../../shared/widgets/album_art_widget.dart';
import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../audio_player/presentation/providers/history_provider.dart';
import '../../../library/domain/entities/track.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../../smart_playlists/presentation/screens/smart_playlists_screen.dart';
import 'history_screen.dart';
import 'most_played_screen.dart';

/// Home content screen with CustomScrollView layout.
/// Features: Header, Search, Carousel, Quick Actions, Recently Played
class HomeContentScreen extends ConsumerStatefulWidget {
  const HomeContentScreen({super.key});

  @override
  ConsumerState<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends ConsumerState<HomeContentScreen> {
  final PageController _carouselController = PageController(
    viewportFraction: 0.85,
  );
  int _currentCarouselPage = 0;
  bool _hasLoadedSongs = false;

  @override
  void initState() {
    super.initState();
    // Lazy loading: trigger music scanning after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongsIfNeeded();
    });
  }

  void _loadSongsIfNeeded() {
    // Check if mounted to avoid state updates on disposed widget
    if (!mounted) return;

    // Only load if we haven't loaded yet and not currently loading
    final libraryState = ref.read(libraryProvider);
    if (!_hasLoadedSongs &&
        !libraryState.isLoading &&
        libraryState.tracks.isEmpty) {
      _hasLoadedSongs = true;
      ref.read(libraryProvider.notifier).loadSongs();
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final libraryState = ref.watch(libraryProvider);
    final tracks = ref.watch(filteredTracksProvider);

    // Show loading state
    if (libraryState.isLoading && tracks.isEmpty) {
      return _buildLoadingState(flavor, libraryState);
    }

    // Show permission required state
    if (libraryState.isPermissionRequired && tracks.isEmpty) {
      return _buildPermissionRequiredState(flavor);
    }

    // Show empty state
    if (tracks.isEmpty) {
      return _buildEmptyState(flavor);
    }

    // Show normal home content
    return _buildHomeContent(flavor);
  }

  /// Build loading state with progress indicator
  Widget _buildLoadingState(Flavor flavor, LibraryState libraryState) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingIndicatorM3E(
                variant: LoadingIndicatorM3EVariant.contained,
              ),
              const SizedBox(height: 24),
              Text(
                'Escaneando música...',
                style: TextStyle(color: flavor.text, fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (libraryState.totalFiles > 0) ...[
                LinearProgressIndicatorM3E(value: libraryState.progress),
                const SizedBox(height: 8),
                Text(
                  '${libraryState.processedFiles} / ${libraryState.totalFiles} archivos',
                  style: TextStyle(color: flavor.subtext1, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build permission required state with retry button
  Widget _buildPermissionRequiredState(Flavor flavor) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off_rounded, size: 64, color: flavor.yellow),
              const SizedBox(height: 24),
              Text(
                'Permiso requerido',
                style: TextStyle(
                  color: flavor.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Se necesita acceso a los archivos de audio para mostrar tu música.',
                textAlign: TextAlign.center,
                style: TextStyle(color: flavor.subtext1, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ButtonM3E(
                onPressed: _retryPermission,
                label: const Text('Solicitar permiso'),
                icon: const Icon(Icons.refresh_rounded),
                style: ButtonM3EStyle.filled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retry permission request
  void _retryPermission() {
    ref.read(libraryProvider.notifier).loadSongs();
  }

  /// Build empty state when no music is found
  Widget _buildEmptyState(Flavor flavor) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_off_rounded, size: 64, color: flavor.subtext1),
              const SizedBox(height: 24),
              Text(
                'No hay canciones',
                style: TextStyle(
                  color: flavor.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Añade música a tu dispositivo y vuelve a escanear.',
                textAlign: TextAlign.center,
                style: TextStyle(color: flavor.subtext1, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ButtonM3E(
                onPressed: () {
                  ref.read(libraryProvider.notifier).refresh();
                },
                label: const Text('Escanear de nuevo'),
                icon: const Icon(Icons.refresh_rounded),
                style: ButtonM3EStyle.filled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the main home content
  Widget _buildHomeContent(Flavor flavor) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // =====================
          // 1. HEADER SECTION
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Añadidas recientemente',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: flavor.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButtonM3E(
                    icon: Icon(Icons.menu_rounded, color: flavor.text),
                    variant: IconButtonM3EVariant.standard,
                    onPressed: () {
                      // TODO: Open menu/drawer
                    },
                    tooltip: 'Menú',
                  ),
                ],
              ),
            ),
          ),

          // =====================
          // 2. SEARCH SECTION
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: _SearchBarM3E(flavor: flavor),
                ),
              ),
            ),
          ),

          // =====================
          // 3. CAROUSEL SECTION (Recently Added)
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final recentTracks = ref.watch(lastTenTracksProvider);
                        final carouselTracks = recentTracks.isNotEmpty
                            ? recentTracks
                            : <Track>[];
                        final hasTracks = carouselTracks.isNotEmpty;

                        return PageView.builder(
                          controller: _carouselController,
                          itemCount: hasTracks ? carouselTracks.length + 1 : 0,
                          onPageChanged: (index) {
                            setState(() {
                              _currentCarouselPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            // Last card is "View All"
                            if (index == carouselTracks.length) {
                              return _ViewAllCard(flavor: flavor);
                            }

                            final track = carouselTracks[index];
                            final colors = [
                              flavor.mauve,
                              flavor.pink,
                              flavor.sapphire,
                              flavor.yellow,
                            ];
                            final colorValue = colors[index % colors.length];
                            return _TrendingCard(
                              title: track.title,
                              artist: track.artist,
                              cardColor: colorValue,
                              flavor: flavor,
                              dateAdded: track.dateAdded != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      track.dateAdded! * 1000,
                                    )
                                  : null,
                              track: track,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Page indicator
                  Consumer(
                    builder: (context, ref, child) {
                      final recentTracks = ref.watch(lastTenTracksProvider);
                      final itemCount = recentTracks.isNotEmpty
                          ? recentTracks.length + 1
                          : 0;
                      if (itemCount == 0) return const SizedBox.shrink();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          itemCount,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentCarouselPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentCarouselPage == index
                                  ? flavor.mauve
                                  : flavor.surface1,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // =====================
          // 4. QUICK ACTIONS SECTION
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionButton(
                    icon: Icons.history_rounded,
                    label: 'Historial',
                    flavor: flavor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Smart Playlists',
                    flavor: flavor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmartPlaylistsScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.trending_up_rounded,
                    label: 'Más reproducidas',
                    flavor: flavor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MostPlayedScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.shuffle_rounded,
                    label: 'Shuffle',
                    flavor: flavor,
                    onTap: () {
                      // Shuffle all tracks
                      final tracks = ref.read(filteredTracksProvider);
                      if (tracks.isNotEmpty) {
                        final shuffled = List<Track>.from(tracks)..shuffle();
                        ref
                            .read(audioPlayerProvider.notifier)
                            .playTracks(shuffled);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // =====================
          // 5. RECENTLY PLAYED SECTION (Real Data)
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Reproducido recientemente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: flavor.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 175,
              child: Consumer(
                builder: (context, ref, child) {
                  final historyState = ref.watch(historyProvider);
                  final recentlyPlayed = historyState.recentlyPlayed;

                  if (recentlyPlayed.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: flavor.surface0,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: flavor.subtext1,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aún no hay historial',
                                style: TextStyle(
                                  color: flavor.subtext1,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final displayTracks = recentlyPlayed.take(10).toList();
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayTracks.length,
                    itemBuilder: (context, index) {
                      final track = displayTracks[index];
                      return _RecentlyPlayedCard(
                        track: track,
                        flavor: flavor,
                        onTap: () {
                          ref
                              .read(audioPlayerProvider.notifier)
                              .playTracks(displayTracks, startIndex: index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Trending carousel card widget
class _TrendingCard extends ConsumerWidget {
  final String title;
  final String artist;
  final Color cardColor;
  final Flavor flavor;
  final DateTime? dateAdded;
  final Track? track;

  const _TrendingCard({
    required this.title,
    required this.artist,
    required this.cardColor,
    required this.flavor,
    this.dateAdded,
    this.track,
  });

  bool get _isNew {
    if (dateAdded == null) return false;
    final now = DateTime.now();
    final difference = now.difference(dateAdded!);
    return difference.inDays < 7; // Less than 1 week
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Handle artist display: if artist is 'Unknown Artist', show file path info
    final displayArtist = artist == 'Unknown Artist'
        ? 'Unknown Artist'
        : artist;
    final displayTitle = title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, cardColor.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Chip moved to top left - only show if less than 1 week old
                if (_isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_isNew) const SizedBox(height: 12),
                // Artist on top
                Text(
                  displayArtist,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Title below artist
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Play button on the right
                    if (track != null)
                      Builder(
                        builder: (context) {
                          final currentTrack = track!;
                          return IconButtonM3E(
                            icon: Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            variant: IconButtonM3EVariant.standard,
                            onPressed: () {
                              final tracks = ref.read(lastTenTracksProvider);
                              final index = tracks.indexOf(currentTrack);
                              ref
                                  .read(audioPlayerProvider.notifier)
                                  .playTracks(tracks, startIndex: index);
                            },
                            tooltip: 'Reproducir',
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// View All card widget for carousel
class _ViewAllCard extends StatelessWidget {
  final Flavor flavor;

  const _ViewAllCard({required this.flavor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to recent tracks screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const _RecentTracksScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: flavor.surface0,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: flavor.surface1, width: 1),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: flavor.mauve.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: flavor.mauve.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: flavor.mauve.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        color: flavor.mauve,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: flavor.text,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ver todas las pistas',
                    style: TextStyle(
                      color: flavor.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent tracks screen (like library but sorted newest to oldest)
class _RecentTracksScreen extends ConsumerWidget {
  const _RecentTracksScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final recentTracks = ref.watch(recentTracksProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBarM3E(
        titleText: 'Añadidas recientemente',
        backgroundColor: flavor.crust.withValues(alpha: 0.8),
        foregroundColor: flavor.text,
      ),
      body: recentTracks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off_rounded,
                    size: 64,
                    color: flavor.subtext1,
                  ),
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
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: recentTracks.length,
              itemBuilder: (context, index) {
                final track = recentTracks[index];
                return _TrackListTile(track: track, flavor: flavor);
              },
            ),
    );
  }
}

/// Track list tile for recent tracks screen
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
          final tracks = ref.read(recentTracksProvider);
          final index = tracks.indexOf(track);
          ref
              .read(audioPlayerProvider.notifier)
              .playTracks(tracks, startIndex: index);
        },
      ),
      onTap: () {
        final tracks = ref.read(recentTracksProvider);
        final index = tracks.indexOf(track);
        ref
            .read(audioPlayerProvider.notifier)
            .playTracks(tracks, startIndex: index);
      },
    );
  }

  Widget _buildAlbumArt() {
    // Prefer filePath for embedded album art, fallback to albumId
    return AlbumArtWidget(
      filePath: track.filePath,
      albumId: track.albumId,
      size: 48,
      borderRadius: 8,
      placeholderIcon: Icons.music_note_rounded,
    );
  }
}

/// Quick action circular button widget with M3E design.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Flavor flavor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.flavor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: flavor.surface0,
                  shape: BoxShape.circle,
                  border: Border.all(color: flavor.surface1, width: 1),
                ),
                child: Icon(icon, color: flavor.mauve, size: 24),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: flavor.subtext1,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recently played card widget with real track data.
class _RecentlyPlayedCard extends StatelessWidget {
  final Track track;
  final Flavor flavor;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({
    required this.track,
    required this.flavor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square image with album art
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: flavor.surface0,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Placeholder gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            flavor.mauve.withValues(alpha: 0.4),
                            flavor.pink.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Album art
                    AlbumArtWidget(
                      filePath: track.filePath,
                      albumId: track.albumId,
                      size: 130,
                      borderRadius: 0,
                      placeholderIcon: Icons.music_note_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              style: TextStyle(
                color: flavor.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              track.artist,
              style: TextStyle(color: flavor.subtext1, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom SearchBarM3E widget using M3E design tokens.
class _SearchBarM3E extends ConsumerStatefulWidget {
  final Flavor flavor;

  const _SearchBarM3E({required this.flavor});

  @override
  ConsumerState<_SearchBarM3E> createState() => _SearchBarM3EState();
}

class _SearchBarM3EState extends ConsumerState<_SearchBarM3E> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update immediately for UI feedback
    ref.read(searchQueryProvider.notifier).state = value;

    // Debounce the actual search (300ms)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(debouncedSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounceTimer?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(debouncedSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.flavor.surface0,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: widget.flavor.surface1, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: widget.flavor.subtext1, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: TextStyle(color: widget.flavor.text, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar canciones, artistas...',
                hintStyle: TextStyle(
                  color: widget.flavor.subtext1,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Clear button
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: widget.flavor.subtext1,
                size: 20,
              ),
              onPressed: _clearSearch,
              tooltip: 'Limpiar',
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
