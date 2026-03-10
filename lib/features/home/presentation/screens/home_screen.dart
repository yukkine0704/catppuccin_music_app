import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/widgets/morphing_player.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'albums_screen.dart';
import 'home_content_screen.dart';

/// Main home screen shell with bottom navigation (4 tabs).
/// Tab structure: Home, Library, Now Playing, Settings
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const AlbumsScreen(),
    const LibraryScreen(),
    // NowPlayingScreen removed - now handled by MorphingPlayer
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);

    return Scaffold(
      body: Stack(
        children: [
          // First child: Column with IndexedStack (body) and NavigationBar (footer)
          // This ensures MorphingPlayer floats above aligned with the nav bar
          Column(
            children: [
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
              NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: flavor.mantle,
                indicatorColor: flavor.mauve.withValues(alpha: 0.3),
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: flavor.subtext1),
                    selectedIcon: Icon(Icons.home_rounded, color: flavor.mauve),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.album_rounded, color: flavor.subtext1),
                    selectedIcon: Icon(
                      Icons.album_rounded,
                      color: flavor.mauve,
                    ),
                    label: 'Álbumes',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.library_music_outlined,
                      color: flavor.subtext1,
                    ),
                    selectedIcon: Icon(
                      Icons.library_music_rounded,
                      color: flavor.mauve,
                    ),
                    label: 'Biblioteca',
                  ),
                  // Now Playing removed - handled by MorphingPlayer
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined, color: flavor.subtext1),
                    selectedIcon: Icon(
                      Icons.settings_rounded,
                      color: flavor.mauve,
                    ),
                    label: 'Ajustes',
                  ),
                ],
              ),
            ],
          ),

          // MorphingPlayer - last child in Stack (floats above everything)
          const MorphingPlayer(),
        ],
      ),
    );
  }
}
