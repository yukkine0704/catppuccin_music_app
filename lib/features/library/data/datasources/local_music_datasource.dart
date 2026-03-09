
import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/track.dart';

/// Data source que utiliza photo_manager para interactuar con los archivos
/// multimedia del sistema de forma moderna y compatible con Android 13+.
class LocalMusicDatasource {

  /// Solicita permisos usando el gestor interno de photo_manager,
  /// el cual ya está adaptado para los permisos granulares de Android modernos.
  Future<bool> requestPermissions() async {
    // requestPermissionExtend maneja automáticamente las diferencias entre OS
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  /// Obtiene todos los archivos de audio del dispositivo.
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

      // 1. Obtenemos los "álbumes" (carpetas del sistema) que contienen audio
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
      );

      if (paths.isEmpty) {
        return const Right([]);
      }

      // 2. La primera ruta siempre es "Recent" (Todos los audios combinados)
      final AssetPathEntity allAudioPath = paths.first;
      final int totalFiles = await allAudioPath.assetCountAsync;

      if (totalFiles == 0) {
        return const Right([]);
      }

      onProgress?.call(totalFiles, 0);

      // 3. Obtenemos los assets (Puedes paginar aquí si son más de 10,000)
      final List<AssetEntity> audioAssets = await allAudioPath
          .getAssetListPaged(page: 0, size: totalFiles);

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
        }

        // Reporte de progreso
        if (i % 20 == 0) {
          onProgress?.call(totalFiles, i + 1);
        }
      }

      onProgress?.call(totalFiles, totalFiles);
      return Right(tracks);
    } catch (e) {
      return Left(DatabaseFailure('Error al consultar archivos: $e'));
    }
  }

  /// Con photo_manager, las carátulas se pueden obtener directamente del AssetEntity
  /// usando asset.thumbnailData. Dejamos este método para compatibilidad de la interfaz.
  Future<dynamic> getArtwork(int id) async {
    return null;
  }
}
