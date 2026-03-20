/// Represents a single line of lyrics with its timestamp.
class LyricLine {
  /// The timestamp when this line should be displayed.
  final Duration timestamp;

  /// The text content of this lyric line.
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LyricLine &&
        other.timestamp == timestamp &&
        other.text == text;
  }

  @override
  int get hashCode => timestamp.hashCode ^ text.hashCode;

  @override
  String toString() => 'LyricLine(timestamp: $timestamp, text: $text)';
}
