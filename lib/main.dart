import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'core/di/injection_container.dart';
import 'core/theme/catppuccin_theme.dart';
import 'features/audio_player/data/datasources/audio_player_service.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  // Start audio service
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

  runApp(const ProviderScope(child: TheVinylSanctuaryApp()));
}

/// Main application widget.
class TheVinylSanctuaryApp extends StatelessWidget {
  const TheVinylSanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Vinyl Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: CatppuccinTheme.mochaTheme,
      darkTheme: CatppuccinTheme.mochaTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
