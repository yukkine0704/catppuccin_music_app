import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import '../../../audio_player/presentation/screens/now_playing_screen.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Main home screen with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LibraryScreen(),
    const NowPlayingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final flavor = catppuccin.mocha;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
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
            icon: Icon(Icons.library_music_outlined, color: flavor.subtext1),
            selectedIcon: Icon(
              Icons.library_music_rounded,
              color: flavor.mauve,
            ),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.play_circle_outline_rounded,
              color: flavor.subtext1,
            ),
            selectedIcon: Icon(Icons.play_circle_rounded, color: flavor.mauve),
            label: 'Reproduciendo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: flavor.subtext1),
            selectedIcon: Icon(Icons.settings_rounded, color: flavor.mauve),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
