import 'package:dio/dio.dart';

/// Data source for fetching album art from external APIs.
class MetadataFetcherDatasource {
  final Dio _dio;

  MetadataFetcherDatasource(this._dio);

  /// Searches for album art using MusicBrainz API.
  Future<String?> fetchAlbumArtFromMusicBrainz({
    required String artist,
    required String album,
  }) async {
    try {
      // First search for the release
      final searchResponse = await _dio.get(
        'https://musicbrainz.org/ws/2/release/',
        queryParameters: {
          'query': 'artist:$artist AND release:$album',
          'fmt': 'json',
          'limit': 1,
        },
      );

      if (searchResponse.data['releases'] == null ||
          (searchResponse.data['releases'] as List).isEmpty) {
        return null;
      }

      final releaseId = searchResponse.data['releases'][0]['id'];

      // Get cover art archive
      final coverResponse = await _dio.get(
        'https://coverartarchive.org/release/$releaseId/front',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      // Return the image URL from coverartarchive
      return 'https://coverartarchive.org/release/$releaseId/front';
    } catch (e) {
      // Try fallback to Last.fm
      return fetchAlbumArtFromLastFm(artist: artist, album: album);
    }
  }

  /// Fallback: Searches for album art using Last.fm API.
  Future<String?> fetchAlbumArtFromLastFm({
    required String artist,
    required String album,
  }) async {
    try {
      // Note: In production, you'd use an API key
      // This is a simplified version that would need an API key
      final response = await _dio.get(
        'https://ws.audioscrobbler.com/2.0/',
        queryParameters: {
          'method': 'album.getinfo',
          'artist': artist,
          'album': album,
          'api_key': 'YOUR_API_KEY', // Replace with actual API key
          'format': 'json',
        },
      );

      if (response.data['album'] != null &&
          response.data['album']['image'] != null) {
        final images = response.data['album']['image'] as List;
        // Get largest available image
        for (var i = images.length - 1; i >= 0; i--) {
          final url = images[i]['#text'];
          if (url != null && url.isNotEmpty) {
            return url;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Downloads image bytes from URL.
  Future<List<int>?> downloadImage(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
