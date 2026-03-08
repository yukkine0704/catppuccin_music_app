import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import 'core/di/injection_container.dart';
import 'core/theme/catppuccin_theme.dart';
import 'features/audio_player/data/datasources/audio_player_service.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/settings/presentation/providers/flavor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[MAIN] Starting app initialization...');

  // Initialize dependencies
  debugPrint('[MAIN] Initializing dependencies...');
  await initializeDependencies();
  debugPrint('[MAIN] Dependencies initialized');

  debugPrint('[MAIN] Initializing Google Fonts cache...');
  // Pre-load Google Fonts to trigger cache initialization before widget tree builds
  // This prevents SQLite database lock when theme builds
  try {
    // Just calling the font function triggers cache initialization
    GoogleFonts.lexend();
    debugPrint('[MAIN] Google Fonts cache initialized');
  } catch (e) {
    debugPrint('[MAIN] Google Fonts initialization warning: $e');
  }

  debugPrint('[MAIN] Starting audio service...');
  // Start audio service with error handling
  // Using Future.delayed to ensure Flutter engine is fully ready
  try {
    await Future.delayed(const Duration(milliseconds: 500));
    await AudioService.init(
      builder: () => AudioPlayerService(AudioPlayer()),
      config: const AudioServiceConfig(
        androidNotificationChannelId:
            'com.example.catppuccin_music_app.channel.audio',
        androidNotificationChannelName: 'The Vinyl Sanctuary',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
    debugPrint('[MAIN] Audio service initialized successfully');
  } catch (e, stack) {
    debugPrint('[MAIN] Audio service initialization failed (non-fatal): $e');
    debugPrint('[MAIN] Stack: $stack');
  }

  debugPrint('[MAIN] Audio service initialized, running app...');
  runApp(const ProviderScope(child: TheVinylSanctuaryApp()));
}

/// Main application widget.
class TheVinylSanctuaryApp extends ConsumerWidget {
  const TheVinylSanctuaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the flavor provider to rebuild theme when it changes
    final flavor = ref.watch(flavorProvider);
    final theme = CatppuccinTheme.buildTheme(flavor);

    return MaterialApp(
      title: 'The Vinyl Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
