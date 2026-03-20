import 'dart:io';

import '../../../../core/utils/lrc_parser.dart';
import '../../domain/entities/lyric_line.dart';

/// Data source for loading lyrics files (.lrc).
///
/// Searches for .lrc files in:
/// - Same directory as the audio file
/// - A "lyrics" subdirectory in the same location
class LyricsDataSource {
  /// Loads lyrics for a given audio file path.
  ///
  /// Searches for .lrc files with the same name as the audio file.
  /// Returns empty list if no lyrics file is found.
  Future<List<LyricLine>> loadLyrics(String audioFilePath) async {
    try {
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return [];
      }

      final audioDir = audioFile.parent;
      final baseName = _getBaseName(audioFilePath);

      // List of possible lyrics file paths to try
      final lrcPaths = [
        // Same directory as audio file
        File(audioFile.path.replaceAll(RegExp(r'\.[^.]+$'), '.lrc')),
        // With _lyrics suffix
        File(audioFile.path.replaceAll(RegExp(r'\.[^.]+$'), '_lyrics.lrc')),
        // In lyrics subdirectory
        File('${audioDir.path}/lyrics/$baseName.lrc'),
        // lyrics subdirectory with _lyrics suffix
        File('${audioDir.path}/lyrics/${baseName}_lyrics.lrc'),
      ];

      // Try each potential lyrics file path
      for (final lrcPath in lrcPaths) {
        if (await lrcPath.exists()) {
          try {
            final content = await lrcPath.readAsString();
            final lyrics = LrcParser.parse(content);
            if (lyrics.isNotEmpty) {
              return lyrics;
            }
          } catch (e) {
            // Try next path if this one fails
            continue;
          }
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Gets the base name of a file path (without extension).
  String _getBaseName(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }
}
