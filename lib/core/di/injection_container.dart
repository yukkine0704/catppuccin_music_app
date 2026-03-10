import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/library/data/datasources/local_music_datasource.dart';
import '../../features/metadata_fetcher/data/datasources/metadata_fetcher_datasource.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies for the application.
/// Uses singleton checks to prevent double registration when called from multiple isolates.
Future<void> initializeDependencies() async {
  debugPrint('[DI] Starting dependency injection...');

  // External - Singleton protection
  if (!getIt.isRegistered<Dio>()) {
    debugPrint('[DI] Registering Dio...');
    getIt.registerLazySingleton<Dio>(() => Dio());
  }

  // Audio Player - Singleton protection
  if (!getIt.isRegistered<AudioPlayer>()) {
    debugPrint('[DI] Registering AudioPlayer...');
    getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  }

  // Note: AudioHandler is registered in main.dart after AudioService.init
  // to ensure we get the actual handler that AudioService is using.
  // This prevents issues with isolate-based audio processing.

  // Data Sources - Singleton protection
  if (!getIt.isRegistered<LocalMusicDatasource>()) {
    debugPrint('[DI] Registering LocalMusicDatasource...');
    getIt.registerLazySingleton<LocalMusicDatasource>(
      () => LocalMusicDatasource(),
    );
  }

  if (!getIt.isRegistered<MetadataFetcherDatasource>()) {
    debugPrint('[DI] Registering MetadataFetcherDatasource...');
    getIt.registerLazySingleton<MetadataFetcherDatasource>(
      () => MetadataFetcherDatasource(getIt<Dio>()),
    );
  }

  debugPrint('[DI] Dependency injection complete');
}
