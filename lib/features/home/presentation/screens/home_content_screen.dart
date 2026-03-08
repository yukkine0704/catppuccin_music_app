import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../audio_player/presentation/providers/audio_player_provider.dart';
import '../../../library/domain/entities/track.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
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

  // Mock data for recently played
  final List<Map<String, String>> _recentlyPlayedData = [
    {'title': 'Neon Nights', 'artist': 'Synth Wave'},
    {'title': 'Ocean Breeze', 'artist': 'Chill Masters'},
    {'title': 'Electric Heart', 'artist': 'Pop Stars'},
    {'title': 'Golden Hour', 'artist': 'Sunset Club'},
    {'title': 'Midnight Run', 'artist': 'Night Owl'},
    {'title': 'Crystal Clear', 'artist': 'Ambient Zone'},
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);

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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar canciones, artistas...',
                  hintStyle: TextStyle(color: flavor.subtext1),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: flavor.subtext1,
                  ),
                  filled: true,
                  fillColor: flavor.surface0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: TextStyle(color: flavor.text),
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
                              const Color(0xFF6366F1),
                              const Color(0xFFEC4899),
                              const Color(0xFF14B8A6),
                              const Color(0xFFF59E0B),
                            ];
                            final colorValue = colors[index % colors.length];
                            return _TrendingCard(
                              title: track.title,
                              artist: track.artist,
                              cardColor: colorValue,
                              flavor: flavor,
                              dateAdded: track.dateAdded,
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
                    icon: Icons.favorite_rounded,
                    label: 'Favoritos',
                    flavor: flavor,
                    onTap: () {
                      // TODO: Navigate to favorites
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
          // 5. RECENTLY PLAYED SECTION
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Recently played',
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentlyPlayedData.length,
                itemBuilder: (context, index) {
                  final item = _recentlyPlayedData[index];
                  return _RecentlyPlayedCard(
                    title: item['title']!,
                    artist: item['artist']!,
                    flavor: flavor,
                    onTap: () {},
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

/// Quick action circular button widget
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
    return GestureDetector(
      onTap: onTap,
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
            child: IconButtonM3E(
              icon: Icon(icon, color: flavor.mauve, size: 24),
              variant: IconButtonM3EVariant.tonal,
              onPressed: onTap,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: flavor.subtext1, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Recently played square card widget
class _RecentlyPlayedCard extends StatelessWidget {
  final String title;
  final String artist;
  final Flavor flavor;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({
    required this.title,
    required this.artist,
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
            // Square image placeholder
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
              child: Stack(
                children: [
                  // Placeholder gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                  // Music icon
                  Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: flavor.text.withValues(alpha: 0.6),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: flavor.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              artist,
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
