import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/widgets/animated_player_sheet.dart';
import '../../../audio_player/presentation/widgets/mini_player.dart';
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
    // NowPlayingScreen removed - will be shown via DraggableScrollableSheet
    const SettingsScreen(),
  ];

  /// Shows the NowPlayingScreen as an animated player sheet.
  void _showNowPlayingSheet(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AnimatedPlayerSheet(onClose: () => Navigator.of(context).pop()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide up transition from mini player position
          const begin = Offset(0.0, 0.3);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player - always visible above navigation bar
          MiniPlayer(onTap: () => _showNowPlayingSheet(context)),
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
                selectedIcon: Icon(Icons.album_rounded, color: flavor.mauve),
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
              // Now Playing removed - handled by mini-player sheet
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: flavor.subtext1),
                selectedIcon: Icon(Icons.settings_rounded, color: flavor.mauve),
                label: 'Ajustes',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
