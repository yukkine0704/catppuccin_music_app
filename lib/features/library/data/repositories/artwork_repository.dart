import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint(
      '[ArtworkRepository] getAlbumArtWithColors - filePath: $filePath, flavor: $flavor',
    );

    final bytesResult = await getArtworkFromFile(filePath);

    // Use synchronous fold - cannot use async here
    final AlbumArt result;

    if (bytesResult.isLeft()) {
      final failure = bytesResult.fold((l) => l, (_) => null);
      debugPrint('[ArtworkRepository] Error getting bytes: $failure');
      return Left(failure ?? DatabaseFailure('Unknown error'));
    }

    final bytes = bytesResult.fold((_) => null, (b) => b);

    if (bytes == null || bytes.isEmpty) {
      debugPrint('[ArtworkRepository] No artwork bytes found for: $filePath');
      return const Right(AlbumArt(bytes: null));
    }

    debugPrint(
      '[ArtworkRepository] Found artwork bytes: ${bytes.length} bytes',
    );

    // Extract colors lazily
    final dominantColor = await AlbumColorExtractor.extractDominantColor(bytes);

    debugPrint('[ArtworkRepository] Dominant color extracted: $dominantColor');

    Color? accentColor;
    if (dominantColor != null &&
        AlbumColorExtractor.isColorful(dominantColor)) {
      accentColor = AlbumColorMapper.findClosestAccent(dominantColor, flavor);
      debugPrint(
        '[ArtworkRepository] Accent color found: $accentColor (from $dominantColor)',
      );
    } else {
      debugPrint(
        '[ArtworkRepository] No accent color - dominantColor: $dominantColor, isColorful: ${dominantColor != null && AlbumColorExtractor.isColorful(dominantColor)}',
      );
    }

    return Right(
      AlbumArt(
        bytes: bytes,
        dominantColor: dominantColor,
        accentColor: accentColor,
      ),
    );
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
