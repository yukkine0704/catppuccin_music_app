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

  // Singleton Protection: Only register if not already registered by audio isolate
  if (!getIt.isRegistered<AudioPlayer>()) {
    debugPrint('[MAIN] Initializing dependencies for the first time...');
    await initializeDependencies();
  }

  // Google Fonts Cache (lightweight, runs in main isolate)
  try {
    GoogleFonts.lexend();
  } catch (_) {}

  // Initialize AudioService and capture the resulting handler
  // AudioService.init must be called after Flutter engine is ready
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerService(getIt<AudioPlayer>()),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.example.catppuccin_music_app.channel.audio',
      androidNotificationChannelName: 'The Vinyl Sanctuary',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Register AudioHandler as Singleton for global access
  // This ensures we always get the same handler that AudioService is using
  if (!getIt.isRegistered<AudioHandler>()) {
    getIt.registerSingleton<AudioHandler>(audioHandler);
  }

  runApp(const ProviderScope(child: TheVinylSanctuaryApp()));
}

class TheVinylSanctuaryApp extends ConsumerWidget {
  const TheVinylSanctuaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final theme = CatppuccinTheme.buildTheme(flavor);

    return MaterialApp(
      title: 'The Vinyl Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
