import '../../features/lyrics/domain/entities/lyric_line.dart';

/// Parser for LRC (Lyric) file format.
///
/// Supports:
/// - Timestamps in format [mm:ss.xx] or [mm:ss]
/// - Metadata tags: [ti:Title], [ar:Artist], [al:Album]
/// - Multiple timestamps per line
class LrcParser {
  /// Regular expression to match LRC timestamps.
  /// Matches [mm:ss.xx] or [mm:ss] format
  static final RegExp _timestampRegex = RegExp(
    r'\[(\d{2}):(\d{2})(?:\.(\d{2}))?\]',
  );

  /// Regular expression to match metadata tags.
  static final RegExp _metadataRegex = RegExp(r'\[(\w+):([^\]]*)\]');

  /// Parses LRC content and returns a list of LyricLine objects.
  ///
  /// Returns empty list if content is invalid or empty.
  static List<LyricLine> parse(String content) {
    if (content.isEmpty) {
      return [];
    }

    final List<LyricLine> lyrics = [];
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      }

      // Try to extract timestamps and text
      final timestamps = <Duration>[];
      String text = trimmedLine;

      // Find all timestamps in the line
      final timestampMatches = _timestampRegex.allMatches(trimmedLine);
      for (final match in timestampMatches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centiseconds = match.group(3) != null
            ? int.parse(match.group(3)!)
            : 0;

        timestamps.add(
          Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: centiseconds * 10,
          ),
        );

        // Remove the timestamp from text
        text = text.replaceFirst(match.group(0)!, '');
      }

      // Clean up text
      text = text.trim();

      // Skip metadata-only lines (lines that only contain tags without lyrics)
      if (text.isEmpty && timestamps.isNotEmpty) {
        continue;
      }

      // Skip empty lines
      if (text.isEmpty) {
        continue;
      }

      // Add a lyric line for each timestamp
      // If there are multiple timestamps, create multiple lines
      for (final timestamp in timestamps) {
        lyrics.add(LyricLine(timestamp: timestamp, text: text));
      }
    }

    // Sort by timestamp
    lyrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return lyrics;
  }

  /// Extracts metadata from LRC content.
  ///
  /// Returns a map with keys: ti, ar, al, etc.
  static Map<String, String> parseMetadata(String content) {
    final Map<String, String> metadata = {};
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      }

      // Check if line contains only metadata (no timestamps)
      final hasTimestamp = _timestampRegex.hasMatch(trimmedLine);
      if (hasTimestamp) {
        continue;
      }

      // Try to match metadata tags
      final match = _metadataRegex.firstMatch(trimmedLine);
      if (match != null) {
        final tag = match.group(1)!.toLowerCase();
        final value = match.group(2)!.trim();

        // Only store known metadata tags
        if ([
          'ti',
          'ar',
          'al',
          'au',
          'length',
          'by',
          'offset',
          're',
          've',
        ].contains(tag)) {
          metadata[tag] = value;
        }
      }
    }

    return metadata;
  }
}
