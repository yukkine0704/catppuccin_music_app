
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/track.dart';

/// Data source que utiliza photo_manager para interactuar con los archivos
/// multimedia del sistema de forma moderna y compatible con Android 13+.
class LocalMusicDatasource {

  /// Solicita permisos usando el gestor interno de photo_manager,
  /// el cual ya está adaptado para los permisos granulares de Android modernos.
  /// RequestPermissionExtend maneja automáticamente RequestType.audio cuando se
  /// llama a getAssetPathList con ese tipo.
  Future<bool> requestPermissions() async {
    // Solicitud de permisos para audio
    // photo_manager maneja internamente el tipo de permiso basado en RequestType.audio
    // Necesitamos especificar el tipo de permiso explícitamente para Android 13+
    final PermissionState ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.audio,
          mediaLocation: false,
        ),
      ),
    );

    // Preventive logs para verificar el estado del permiso
    debugPrint(
      'PhotoManager permission state - isAuth: ${ps.isAuth}, '
      'hasAccess: ${ps.hasAccess}',
    );

    // Verificación adicional del estado - ambos métodos deben verificar acceso
    if (!ps.isAuth && !ps.hasAccess) {
      debugPrint('ADVERTENCIA: Permiso de audio no concedido. Estado: $ps');
    }

    return ps.isAuth || ps.hasAccess;
  }

  /// Obtiene todos los archivos de audio del dispositivo.
  /// Utiliza photo_manager con RequestType.audio para obtener solo archivos de audio.
  Future<Either<Failure, List<Track>>> getAllSongs({
    void Function(int total, int processed)? onProgress,
  }) async {
    try {
      debugPrint('Iniciando solicitud de permisos de audio...');

      final hasPermission = await requestPermissions();

      if (!hasPermission) {
        debugPrint(
          'PERMISO DENEGADO: No se pudo obtener acceso a los archivos de audio',
        );
        return const Left(
          PermissionFailure('Permiso de acceso a música denegado'),
        );
      }

      debugPrint('Permiso concedido, iniciando carga de archivos de audio...');

      // 1. Obtenemos los "álbumes" (carpetas del sistema) que contienen audio
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
      );

      debugPrint(
        'Se encontraron ${paths.length} carpetas con archivos de audio',
      );

      if (paths.isEmpty) {
        debugPrint('No se encontraron archivos de audio en el dispositivo');
        return const Right([]);
      }

      // 2. La primera ruta siempre es "Recent" (Todos los audios combinados)
      final AssetPathEntity allAudioPath = paths.first;
      final int totalFiles = await allAudioPath.assetCountAsync;

      debugPrint('Total de archivos de audio encontrados: $totalFiles');

      if (totalFiles == 0) {
        return const Right([]);
      }

      onProgress?.call(totalFiles, 0);

      // 3. Obtenemos los assets (Puedes paginar aquí si son más de 10,000)
      final List<AssetEntity> audioAssets = await allAudioPath
          .getAssetListPaged(page: 0, size: totalFiles);

      debugPrint('Cargando ${audioAssets.length} assets de audio...');

      final List<Track> tracks = [];

      // 4. Mapeo de AssetEntity a tu entidad Track
      for (var i = 0; i < audioAssets.length; i++) {
        final asset = audioAssets[i];

        // Obtenemos el archivo físico para sacar la ruta
        final file = await asset.file;

        if (file != null) {
          tracks.add(
            Track(
              // Convertimos el ID String del sistema a int, o usamos el hashCode como fallback
              id: int.tryParse(asset.id) ?? asset.id.hashCode,
              title: asset.title ?? 'Pista sin título',

              // Nota: photo_manager no lee etiquetas ID3 (Artista/Álbum) nativamente.
              // Estos datos base te permitirán arrancar.
              artist: 'Artista Desconocido',
              album: 'Álbum Desconocido',

              filePath: file.path,
              // photo_manager devuelve la duración en segundos, la pasamos a ms
              duration: asset.duration * 1000,

              // Usamos el hash de la ruta relativa (carpeta) para agrupar álbumes temporalmente
              albumId: asset.relativePath?.hashCode,
              genre: null,
              year: asset.createDateTime.year,
              trackNumber: null,
              dateAdded: asset.createDateTime.millisecondsSinceEpoch ~/ 1000,
            ),
          );
        } else {
          debugPrint(
            'ADVERTENCIA: No se pudo obtener archivo para asset: ${asset.title}',
          );
        }

        // Reporte de progreso
        if (i % 20 == 0) {
          onProgress?.call(totalFiles, i + 1);
        }
      }

      onProgress?.call(totalFiles, totalFiles);
      debugPrint(
        'Carga de tracks completada: ${tracks.length} pistas cargadas',
      );
      return Right(tracks);
    } catch (e) {
      debugPrint('ERROR al consultar archivos de audio: $e');
      return Left(DatabaseFailure('Error al consultar archivos: $e'));
    }
  }

  /// Con photo_manager, las carátulas se pueden obtener directamente del AssetEntity
  /// usando asset.thumbnailData. Dejamos este método para compatibilidad de la interfaz.
  Future<dynamic> getArtwork(int id) async {
    return null;
  }
}
