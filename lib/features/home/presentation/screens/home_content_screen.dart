import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

/// Home content screen with CustomScrollView layout.
/// Features: Header, Search, Carousel, Quick Actions, Recently Played
class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final PageController _carouselController = PageController(
    viewportFraction: 0.85,
  );
  int _currentCarouselPage = 0;

  // Mock data for trending carousel
  final List<Map<String, String>> _trendingData = [
    {
      'title': 'Midnight Vibes',
      'artist': 'The Lo-Fi Collective',
      'color': '0xFF6366F1',
    },
    {'title': 'Summer Heat', 'artist': 'Tropical Waves', 'color': '0xFFEC4899'},
    {'title': 'Urban Dreams', 'artist': 'City Lights', 'color': '0xFF14B8A6'},
    {'title': 'Retro Soul', 'artist': 'Classic Beats', 'color': '0xFFF59E0B'},
  ];

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
    final flavor = catppuccin.mocha;

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
                    'Hot Releases',
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
          // 3. CAROUSEL SECTION (Trending)
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: _trendingData.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCarouselPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _trendingData[index];
                        final colorValue = int.parse(item['color']!);
                        return _TrendingCard(
                          title: item['title']!,
                          artist: item['artist']!,
                          cardColor: Color(colorValue),
                          flavor: flavor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _trendingData.length,
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
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.favorite_rounded,
                    label: 'Favoritos',
                    flavor: flavor,
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.trending_up_rounded,
                    label: 'Más reproducidas',
                    flavor: flavor,
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.shuffle_rounded,
                    label: 'Shuffle',
                    flavor: flavor,
                    onTap: () {},
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
class _TrendingCard extends StatelessWidget {
  final String title;
  final String artist;
  final Color cardColor;
  final Flavor flavor;

  const _TrendingCard({
    required this.title,
    required this.artist,
    required this.cardColor,
    required this.flavor,
  });

  @override
  Widget build(BuildContext context) {
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
                    'Trending',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            child: Icon(icon, color: flavor.mauve, size: 24),
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
