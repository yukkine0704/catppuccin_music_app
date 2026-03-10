import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/utils/album_color_extractor.dart';
import '../../../../core/theme/utils/album_color_mapper.dart';

/// Entity representing extracted album artwork with colors.
class AlbumArt {
  final Uint8List? bytes;
  final Color? dominantColor;
  final Color? accentColor;

  const AlbumArt({this.bytes, this.dominantColor, this.accentColor});

  bool get hasArtwork => bytes != null && bytes!.isNotEmpty;
}

/// Repository for artwork operations.
/// Coordinates extraction of album art and color mapping.
class ArtworkRepository {
  ArtworkRepository();

  /// Gets artwork from file path (preferred method).
  /// Extracts embedded album art from the audio file.
  Future<Either<Failure, Uint8List?>> getArtworkFromFile(
    String? filePath,
  ) async {
    if (filePath == null || filePath.isEmpty) {
      return const Right(null);
    }

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return const Right(null);
      }

      final metadata = readMetadata(file, getImage: true);

      if (metadata.pictures.isNotEmpty) {
        final picture = metadata.pictures.first;
        final bytes = picture.bytes;

        if (bytes.isNotEmpty) {
          return Right(bytes);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to extract artwork: $e'));
    }
  }

  /// Gets artwork with colors from file path.
  /// This is a lazy operation - colors are extracted only when needed.
  Future<Either<Failure, AlbumArt>> getAlbumArtWithColors(
    String? filePath,
    Flavor flavor,
  ) async {
    final bytesResult = await getArtworkFromFile(filePath);

    return bytesResult.fold((failure) => Left(failure), (bytes) async {
      if (bytes == null || bytes.isEmpty) {
        return const Right(AlbumArt(bytes: null));
      }

      // Extract colors lazily
      final dominantColor = await AlbumColorExtractor.extractDominantColor(
        bytes,
      );

      Color? accentColor;
      if (dominantColor != null &&
          AlbumColorExtractor.isColorful(dominantColor)) {
        accentColor = AlbumColorMapper.findClosestAccent(dominantColor, flavor);
      }

      return Right(
        AlbumArt(
          bytes: bytes,
          dominantColor: dominantColor,
          accentColor: accentColor,
        ),
      );
    });
  }

  /// Gets accent color from genre (fallback when no artwork).
  /// Maps genre to Catppuccin accent color.
  Color getAccentFromGenre(String? genre, Flavor flavor) {
    return AlbumColorMapper.getGenreAccent(genre, flavor);
  }

  /// Gets default accent color for the flavor.
  Color getDefaultAccent(Flavor flavor) {
    return flavor.mauve;
  }
}
