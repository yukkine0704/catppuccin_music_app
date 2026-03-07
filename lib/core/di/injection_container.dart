import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/audio_player/data/datasources/audio_player_service.dart';
import '../../features/library/data/datasources/local_music_datasource.dart';
import '../../features/metadata_fetcher/data/datasources/metadata_fetcher_datasource.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies for the application.
Future<void> initializeDependencies() async {
  // External
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Audio Player
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // Services
  getIt.registerLazySingleton<AudioHandler>(
    () => AudioPlayerService(getIt<AudioPlayer>()),
  );

  // Data Sources
  getIt.registerLazySingleton<LocalMusicDatasource>(
    () => LocalMusicDatasource(),
  );

  getIt.registerLazySingleton<MetadataFetcherDatasource>(
    () => MetadataFetcherDatasource(getIt<Dio>()),
  );
}
