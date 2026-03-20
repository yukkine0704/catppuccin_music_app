import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/tag_edit.dart';

/// Data source para leer y escribir metadatos de archivos de audio.
/// Utiliza audio_metadata_reader para lectura y SQLite para persistencia.
class TagEditorDatasource {
  final AppDatabase _database;

  TagEditorDatasource(this._database);

  /// Lee los metadatos actuales de un archivo de audio.
  /// Retorna Either<Failure, TagEdit> con los metadatos o un error.
  Future<Either<Failure, TagEdit>> readMetadata(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return const Left(FileSystemFailure('El archivo no existe'));
      }

      // Leer metadatos usando audio_metadata_reader
      amr.AudioMetadata? metadata;
      try {
        metadata = amr.readMetadata(file, getImage: false);
      } catch (e) {
        debugPrint('Error leyendo metadatos: $e');
        // Si falla, usamos valores por defecto
      }

      // También verificamos si existe en la base de datos local
      final dbTrack = await _database.getTrackByFilePath(filePath);

      // Valores con fallback
      final title = metadata?.title ?? dbTrack?.title ?? 'Sin título';
      final artist =
          metadata?.artist ?? dbTrack?.artist ?? 'Artista Desconocido';
      final album = metadata?.album ?? dbTrack?.album ?? 'Álbum Desconocido';
      final year = metadata?.year?.year ?? dbTrack?.year;
      final trackNumber = metadata?.trackNumber ?? dbTrack?.trackNumber;
      final albumId = dbTrack?.albumId;

      return Right(
        TagEdit(
          filePath: filePath,
          title: title,
          artist: artist,
          album: album,
          year: year,
          trackNumber: trackNumber,
          albumId: albumId,
        ),
      );
    } catch (e) {
      debugPrint('Error en readMetadata: $e');
      return Left(DatabaseFailure('Error al leer metadatos: $e'));
    }
  }

  /// Escribe los metadatos modificados.
  /// Guarda los cambios en la base de datos SQLite local.
  /// Retorna Either<Failure, void>.
  Future<Either<Failure, void>> writeMetadata(TagEdit tagEdit) async {
    try {
      // Actualizar en la base de datos SQLite
      final result = await _database.updateTrackByFilePath(
        tagEdit.filePath,
        TracksTableCompanion(
          title: Value(tagEdit.title),
          artist: Value(tagEdit.artist),
          album: Value(tagEdit.album),
          year: Value(tagEdit.year),
          genre: Value(tagEdit.genre),
          trackNumber: Value(tagEdit.trackNumber),
        ),
      );

      if (result == 0) {
        // Si no se actualizó ningún registro, el track no existe en la base de datos
        // Insertamos uno nuevo
        await _database.insertTrack(
          TracksTableCompanion(
            trackId: Value(tagEdit.filePath.hashCode),
            title: Value(tagEdit.title),
            artist: Value(tagEdit.artist),
            album: Value(tagEdit.album),
            albumId: Value(tagEdit.albumId),
            filePath: Value(tagEdit.filePath),
            duration: const Value(0),
            year: Value(tagEdit.year),
            genre: Value(tagEdit.genre),
            trackNumber: Value(tagEdit.trackNumber),
            lastScanned: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      debugPrint('Error en writeMetadata: $e');
      return Left(DatabaseFailure('Error al guardar metadatos: $e'));
    }
  }
}
