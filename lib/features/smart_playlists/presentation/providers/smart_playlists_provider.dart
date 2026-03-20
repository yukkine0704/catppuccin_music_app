import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/di/injection_container.dart';
import '../../../library/domain/entities/track.dart';
import '../../data/datasources/smart_playlist_datasource.dart';
import '../../data/repositories/smart_playlist_repository_impl.dart';
import '../../domain/entities/smart_playlist.dart';

/// Provider para el DataSource de Smart Playlists
final smartPlaylistDataSourceProvider = Provider<SmartPlaylistDataSource>((
  ref,
) {
  return SmartPlaylistDataSource(getIt<AppDatabase>());
});

/// Provider para el Repositorio de Smart Playlists
final smartPlaylistRepositoryProvider = Provider<SmartPlaylistRepository>((
  ref,
) {
  final dataSource = ref.watch(smartPlaylistDataSourceProvider);
  return SmartPlaylistRepository(dataSource);
});

/// Provider para obtener la lista de playlists disponibles
final smartPlaylistsProvider = Provider<List<SmartPlaylist>>((ref) {
  final repository = ref.watch(smartPlaylistRepositoryProvider);
  return repository.getPlaylists();
});

/// Provider para obtener las pistas de una playlist específica
final playlistTracksProvider =
    FutureProvider.family<List<Track>, SmartPlaylistType>((ref, type) async {
      final repository = ref.watch(smartPlaylistRepositoryProvider);
      return repository.getTracksForPlaylist(type);
    });

/// Notifier para gestionar el estado de las smart playlists
class SmartPlaylistsNotifier
    extends StateNotifier<AsyncValue<Map<SmartPlaylistType, List<Track>>>> {
  final SmartPlaylistRepository _repository;

  SmartPlaylistsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAllPlaylists();
  }

  /// Carga todas las playlists
  Future<void> loadAllPlaylists() async {
    state = const AsyncValue.loading();
    try {
      final recentlyAdded = await _repository.getTracksForPlaylist(
        SmartPlaylistType.recentlyAdded,
      );
      final mostPlayed = await _repository.getTracksForPlaylist(
        SmartPlaylistType.mostPlayed,
      );

      state = AsyncValue.data({
        SmartPlaylistType.recentlyAdded: recentlyAdded,
        SmartPlaylistType.mostPlayed: mostPlayed,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Incrementa el contador de reproducciones
  Future<void> incrementPlayCount(int trackId) async {
    await _repository.incrementPlayCount(trackId);
    // Recargar las playlists después de incrementar
    await loadAllPlaylists();
  }
}

/// Provider para el notifier de smart playlists
final smartPlaylistsNotifierProvider =
    StateNotifierProvider<
      SmartPlaylistsNotifier,
      AsyncValue<Map<SmartPlaylistType, List<Track>>>
    >((ref) {
      final repository = ref.watch(smartPlaylistRepositoryProvider);
      return SmartPlaylistsNotifier(repository);
    });
