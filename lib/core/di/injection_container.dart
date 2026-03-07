import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/audio_player/data/datasources/audio_player_service.dart';
import '../../features/library/data/datasources/local_music_datasource.dart';
import '../../features/metadata_fetcher/data/datasources/metadata_fetcher_datasource.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies for the application.
Future<void> initializeDependencies() async {
  debugPrint('[DI] Starting dependency injection...');

  // External
  debugPrint('[DI] Registering Dio...');
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Audio Player
  debugPrint('[DI] Registering AudioPlayer...');
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // Services
  debugPrint('[DI] Registering AudioHandler...');
  getIt.registerLazySingleton<AudioHandler>(
    () => AudioPlayerService(getIt<AudioPlayer>()),
  );

  // Data Sources
  debugPrint('[DI] Registering LocalMusicDatasource...');
  getIt.registerLazySingleton<LocalMusicDatasource>(
    () => LocalMusicDatasource(),
  );

  debugPrint('[DI] Registering MetadataFetcherDatasource...');
  getIt.registerLazySingleton<MetadataFetcherDatasource>(
    () => MetadataFetcherDatasource(getIt<Dio>()),
  );

  debugPrint('[DI] Dependency injection complete');
}
