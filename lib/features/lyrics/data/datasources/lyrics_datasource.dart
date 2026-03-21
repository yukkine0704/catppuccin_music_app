import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/lrc_parser.dart';
import '../../domain/entities/lyric_line.dart';

/// Data source for loading lyrics files (.lrc) and online lyrics.
///
/// Searches for .lrc files in:
/// - Same directory as the audio file
/// - A "lyrics" subdirectory in the same location
///
/// Also supports online search via LRCLIB API.
class LyricsDataSource {
  /// LRCLIB API base URL
  static const String _lrclibBaseUrl = 'https://lrclib.net/api';

  /// Regex pattern to match file extension
  static final RegExp _extensionRegex = RegExp(r'\.[^.]+$');

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
        File(audioFile.path.replaceAll(_extensionRegex, '.lrc')),
        // With _lyrics suffix
        File(audioFile.path.replaceAll(_extensionRegex, '_lyrics.lrc')),
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

  /// Searches for lyrics online using the LRCLIB API.
  ///
  /// Returns empty list if no lyrics are found.
  Future<List<LyricLine>> searchOnlineLyrics({
    required String artist,
    required String trackName,
    String? albumName,
    int? durationMs,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'artist_name': _normalizeString(artist),
        'track_name': _normalizeString(trackName),
      };

      if (albumName != null && albumName.isNotEmpty) {
        queryParams['album_name'] = _normalizeString(albumName);
      }

      if (durationMs != null && durationMs > 0) {
        queryParams['duration'] = durationMs.toString();
      }

      final uri = Uri.parse(
        '$_lrclibBaseUrl/get',
      ).replace(queryParameters: queryParams);

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        return [];
      }

      final responseBody = await response.transform(utf8.decoder).join();

      final data = json.decode(responseBody) as Map<String, dynamic>;

      // Check if we got a valid response with lyrics
      final syncedLyrics = data['syncedLyrics'] as String?;
      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        return LrcParser.parse(syncedLyrics);
      }

      // Try plain lyrics if synced not available
      final plainLyrics = data['plainLyrics'] as String?;
      if (plainLyrics != null && plainLyrics.isNotEmpty) {
        // Convert plain lyrics to timed lines (one line = estimated 3 seconds)
        return _convertPlainLyricsToTimed(plainLyrics);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Searches for lyrics with fuzzy matching.
  ///
  /// Uses LRCLIB's getByMatch endpoint for better results.
  Future<List<LyricLine>> searchLyricsFuzzy({
    required String artist,
    required String trackName,
    String? albumName,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': '${_normalizeString(artist)} ${_normalizeString(trackName)}',
      };

      if (albumName != null && albumName.isNotEmpty) {
        queryParams['album_name'] = _normalizeString(albumName);
      }

      final uri = Uri.parse(
        '$_lrclibBaseUrl/getByMatch',
      ).replace(queryParameters: queryParams);

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        return [];
      }

      final responseBody = await response.transform(utf8.decoder).join();

      final decodedData = json.decode(responseBody);

      // Handle getByMatch which returns an array
      if (decodedData is List && decodedData.isNotEmpty) {
        final firstResult = decodedData.first;
        if (firstResult is! Map<String, dynamic>) {
          return [];
        }
        return _parseLyricsFromResponse(firstResult);
      }

      // Handle get which returns a single object
      if (decodedData is Map<String, dynamic>) {
        return _parseLyricsFromResponse(decodedData);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Converts plain (unsynchronized) lyrics to timed lines.
  ///
  /// Estimates ~3 seconds per line as a fallback.
  List<LyricLine> _convertPlainLyricsToTimed(String plainLyrics) {
    final lines = plainLyrics.split('\n');
    final timedLines = <LyricLine>[];

    const estimatedDurationPerLine = Duration(seconds: 3);
    var currentTime = Duration.zero;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      }

      timedLines.add(LyricLine(timestamp: currentTime, text: trimmedLine));

      currentTime += estimatedDurationPerLine;
    }

    return timedLines;
  }

  /// Parses lyrics from an LRCLIB API response.
  List<LyricLine> _parseLyricsFromResponse(Map<String, dynamic> response) {
    final syncedLyrics = response['syncedLyrics'] as String?;

    if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
      return LrcParser.parse(syncedLyrics);
    }

    final plainLyrics = response['plainLyrics'] as String?;
    if (plainLyrics != null && plainLyrics.isNotEmpty) {
      return _convertPlainLyricsToTimed(plainLyrics);
    }

    return [];
  }

  /// Normalizes a string for API queries.
  String _normalizeString(String input) {
    // Remove special characters that might interfere with the API
    return input
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
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

  /// Saves lyrics to an external .lrc file in the same directory as the audio.
  ///
  /// Returns the path where the file was saved, or null if failed.
  Future<String?> saveLyricsToFile(
    String audioFilePath,
    List<LyricLine> lyrics, {
    String? artist,
    String? title,
    String? album,
  }) async {
    try {
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return null;
      }

      final lrcContent = _generateLrcContent(
        lyrics,
        artist: artist,
        title: title,
        album: album,
      );

      // Save in same directory with _lyrics suffix to avoid overwriting
      final lrcPath = audioFile.path.replaceAll(_extensionRegex, '_lyrics.lrc');

      final lrcFile = File(lrcPath);
      await lrcFile.writeAsString(lrcContent);

      debugPrint('[LyricsDataSource] Saved lyrics to: $lrcPath');
      return lrcPath;
    } catch (e) {
      debugPrint('[LyricsDataSource] Error saving lyrics to file: $e');
      return null;
    }
  }

  /// Generates LRC file content from lyric lines with metadata.
  String _generateLrcContent(
    List<LyricLine> lyrics, {
    String? artist,
    String? title,
    String? album,
  }) {
    final buffer = StringBuffer();

    // Add metadata tags
    if (title != null && title.isNotEmpty) {
      buffer.writeln('[ti:$title]');
    }
    if (artist != null && artist.isNotEmpty) {
      buffer.writeln('[ar:$artist]');
    }
    if (album != null && album.isNotEmpty) {
      buffer.writeln('[al:$album]');
    }

    // Add empty line between metadata and lyrics
    buffer.writeln();

    // Add synchronized lyrics
    for (final line in lyrics) {
      final timestamp = _formatTimestamp(line.timestamp);
      buffer.writeln('[$timestamp]${line.text}');
    }

    return buffer.toString();
  }

  /// Formats duration to LRC timestamp format [mm:ss.xx].
  String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centiseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  /// Deletes a saved .lrc file for the given audio file path.
  ///
  /// Returns true if deleted successfully, false otherwise.
  Future<bool> deleteLyricsFile(String audioFilePath) async {
    try {
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return false;
      }

      // Try both possible filenames
      final lrcPath1 = audioFile.path.replaceAll(_extensionRegex, '.lrc');
      final lrcPath2 = audioFile.path.replaceAll(
        _extensionRegex,
        '_lyrics.lrc',
      );

      final file1 = File(lrcPath1);
      final file2 = File(lrcPath2);

      bool deleted = false;
      if (await file1.exists()) {
        await file1.delete();
        deleted = true;
      }
      if (await file2.exists()) {
        await file2.delete();
        deleted = true;
      }

      return deleted;
    } catch (e) {
      debugPrint('[LyricsDataSource] Error deleting lyrics file: $e');
      return false;
    }
  }

  /// Checks if a lyrics file exists for the given audio file path.
  Future<bool> hasLyricsFile(String audioFilePath) async {
    try {
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return false;
      }

      // Check both possible filenames
      final lrcPath1 = audioFile.path.replaceAll(_extensionRegex, '.lrc');
      final lrcPath2 = audioFile.path.replaceAll(
        _extensionRegex,
        '_lyrics.lrc',
      );

      return await File(lrcPath1).exists() || await File(lrcPath2).exists();
    } catch (e) {
      return false;
    }
  }
}
