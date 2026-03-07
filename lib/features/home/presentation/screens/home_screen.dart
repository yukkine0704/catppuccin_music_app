import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import '../../../audio_player/presentation/screens/now_playing_screen.dart';
import '../../../audio_player/presentation/widgets/mini_player.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'home_content_screen.dart';

/// Main home screen shell with bottom navigation (4 tabs).
/// Tab structure: Home, Library, Now Playing, Settings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const LibraryScreen(),
    // NowPlayingScreen removed - will be shown via DraggableScrollableSheet
    const SettingsScreen(),
  ];

  /// Shows the NowPlayingScreen as a draggable bottom sheet.
  void _showNowPlayingSheet(BuildContext context) {
    final flavor = catppuccin.mocha;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: flavor.base,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle indicator
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: flavor.surface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: NowPlayingScreen()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flavor = catppuccin.mocha;

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
