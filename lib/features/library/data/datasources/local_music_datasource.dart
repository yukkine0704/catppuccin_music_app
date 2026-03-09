import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/track.dart';

/// Data source que emula el comportamiento de RetroMusicPlayer
/// Utiliza MediaStore (Android) y MPMediaLibrary (iOS) en lugar de escaneo manual.
class LocalMusicDatasource {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Solicita permisos siguiendo los estándares modernos de Android (13+)
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13 (API 33) o superior requiere permisos granulares
      final status = await Permission.audio.status;
      if (status.isPermanentlyDenied) return false;

      if (!status.isGranted) {
        final result = await Permission.audio.request();
        return result.isGranted;
      }
      return true;
    } else {
      // Para iOS u otras versiones de Android
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  /// Obtiene todas las canciones del dispositivo de forma casi instantánea.
  /// No abre los archivos físicamente, solo consulta la base de datos del sistema.
  Future<Either<Failure, List<Track>>> getAllSongs({
    void Function(int total, int processed)? onProgress,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        return const Left(
          PermissionFailure('Permiso de acceso a música denegado'),
        );
      }

      // Consulta a la base de datos de medios (Equivalente a RetroMusicPlayer)
      // Filtramos audios cortos (notificaciones/whatsapp) por defecto
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (songs.isEmpty) {
        return const Right([]);
      }

      final totalFiles = songs.length;
      onProgress?.call(totalFiles, 0);

      // Mapeo de SongModel a tu entidad Track
      // Nota: No extraemos bytes de imagen aquí para evitar errores de memoria (OOM)
      final List<Track> tracks = [];

      for (var i = 0; i < songs.length; i++) {
        final s = songs[i];

        tracks.add(
          Track(
            id: s.id,
            title: s.title,
            artist: s.artist == '<unknown>'
                ? 'Artista Desconocido'
                : (s.artist ?? 'Artista Desconocido'),
            album: s.album == '<unknown>'
                ? 'Álbum Desconocido'
                : (s.album ?? 'Álbum Desconocido'),
            filePath: s.data,
            duration: s.duration ?? 0,
            albumId: s.albumId, // <--- CAMBIO CLAVE: Guardamos el ID del álbum
            genre: s.genre,
            year: s.getMap['year'], // Extraemos el año del mapa interno
            trackNumber: s.track,
            dateAdded: s.dateAdded,
          ),
        );

        // Reporte de progreso (aunque es tan rápido que apenas se notará)
        if (i % 20 == 0) {
          onProgress?.call(totalFiles, i + 1);
        }
      }

      onProgress?.call(totalFiles, totalFiles);
      return Right(tracks);
    } catch (e) {
      return Left(DatabaseFailure('Error al consultar MediaStore: $e'));
    }
  }

  /// Este método ya no es necesario para el escaneo inicial,
  /// pero podrías usarlo para actualizar metadata específica.
  Future<dynamic> getArtwork(int id) async {
    // La carátula se maneja de forma reactiva en la UI
    return null;
  }
}
