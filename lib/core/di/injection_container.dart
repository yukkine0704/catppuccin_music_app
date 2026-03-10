import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/library/data/datasources/local_music_datasource.dart';
import '../../features/library/data/repositories/artwork_repository.dart';
import '../../features/metadata_fetcher/data/datasources/metadata_fetcher_datasource.dart';
import '../../features/settings/data/datasources/shared_prefs_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';

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

  // SharedPreferences - Must be initialized before other dependencies
  if (!getIt.isRegistered<SharedPreferences>()) {
    debugPrint('[DI] Registering SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

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

  if (!getIt.isRegistered<SharedPrefsDatasource>()) {
    debugPrint('[DI] Registering SharedPrefsDatasource...');
    getIt.registerLazySingleton<SharedPrefsDatasource>(
      () => SharedPrefsDatasource(getIt<SharedPreferences>()),
    );
  }

  // Repositories - Singleton protection
  if (!getIt.isRegistered<SettingsRepository>()) {
    debugPrint('[DI] Registering SettingsRepository...');
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(getIt<SharedPrefsDatasource>()),
    );
  }

  if (!getIt.isRegistered<ArtworkRepository>()) {
    debugPrint('[DI] Registering ArtworkRepository...');
    getIt.registerLazySingleton<ArtworkRepository>(() => ArtworkRepository());
  }

  debugPrint('[DI] Dependency injection complete');
}
