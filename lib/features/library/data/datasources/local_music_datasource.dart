import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/track.dart';

/// Data source for accessing local music files using file system scanning.
/// Note: on_audio_query is commented out due to AGP namespace compatibility issues.
/// This is a fallback implementation that scans common music directories.
class LocalMusicDatasource {
  /// Requests storage permissions.
  Future<bool> requestPermissions() async {
    // Request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) return true;

    // Try audio permission for newer Android versions
    var audioStatus = await Permission.audio.status;
    if (!audioStatus.isGranted) {
      audioStatus = await Permission.audio.request();
    }

    return audioStatus.isGranted;
  }

  /// Fetches all songs from local storage.
  Future<List<Track>> getAllSongs() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    final tracks = <Track>[];
    final musicDirs = [
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/DCIM'),
    ];

    int id = 0;
    for (final dir in musicDirs) {
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final path = entity.path.toLowerCase();
            if (path.endsWith('.mp3') ||
                path.endsWith('.m4a') ||
                path.endsWith('.wav') ||
                path.endsWith('.flac')) {
              // Basic metadata extraction from filename
              final fileName = entity.path.split('/').last;
              final nameWithoutExt = fileName.replaceAll(
                RegExp(r'\.[^.]+$'),
                '',
              );
              final parts = nameWithoutExt.split(' - ');

              tracks.add(
                Track(
                  id: id++,
                  title: parts.length > 1 ? parts[1] : nameWithoutExt,
                  artist: parts.isNotEmpty ? parts[0] : 'Unknown Artist',
                  album: 'Unknown Album',
                  filePath: entity.path,
                  duration: 0, // Would need a proper audio decoder
                ),
              );
            }
          }
        }
      }
    }

    return tracks;
  }

  /// Gets artwork for a song (placeholder - would need native implementation).
  Future<dynamic> getArtwork(int id) async {
    return null;
  }
}
