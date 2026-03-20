/// Represents an equalizer preset with predefined band values.
class EqualizerPreset {
  /// Unique identifier for the preset.
  final String id;

  /// Display name of the preset.
  final String name;

  /// Gain values in dB for each frequency band.
  /// Typical bands: 60Hz, 230Hz, 910Hz, 3kHz, 14kHz
  final List<double> bands;

  /// Whether this preset has the equalizer enabled.
  final bool isEnabled;

  const EqualizerPreset({
    required this.id,
    required this.name,
    required this.bands,
    this.isEnabled = true,
  });

  /// Creates a copy with optional overrides.
  EqualizerPreset copyWith({
    String? id,
    String? name,
    List<double>? bands,
    bool? isEnabled,
  }) {
    return EqualizerPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      bands: bands ?? List.from(this.bands),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /// Converts to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bands': bands,
      'isEnabled': isEnabled,
    };
  }

  /// Creates from JSON.
  factory EqualizerPreset.fromJson(Map<String, dynamic> json) {
    return EqualizerPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      bands: (json['bands'] as List).map((e) => (e as num).toDouble()).toList(),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EqualizerPreset) return false;
    return id == other.id &&
        name == other.name &&
        bands.length == other.bands.length &&
        _listEquals(bands, other.bands) &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode => Object.hash(id, name, bands, isEnabled);

  static bool _listEquals(List<double> a, List<double> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Built-in equalizer presets.
class EqualizerPresets {
  /// Flat - no equalization
  static const flat = EqualizerPreset(
    id: 'flat',
    name: 'Flat',
    bands: [0.0, 0.0, 0.0, 0.0, 0.0],
  );

  /// Rock - enhanced bass and treble
  static const rock = EqualizerPreset(
    id: 'rock',
    name: 'Rock',
    bands: [5.0, 3.0, -1.0, 2.0, 5.0],
  );

  /// Pop - enhanced midrange
  static const pop = EqualizerPreset(
    id: 'pop',
    name: 'Pop',
    bands: [-1.0, 2.0, 5.0, 3.0, 0.0],
  );

  /// Jazz - enhanced bass and treble, reduced midrange
  static const jazz = EqualizerPreset(
    id: 'jazz',
    name: 'Jazz',
    bands: [4.0, 2.0, -2.0, 1.0, 4.0],
  );

  /// Classical - enhanced treble, slight bass
  static const classical = EqualizerPreset(
    id: 'classical',
    name: 'Classical',
    bands: [3.0, 1.0, -1.0, 2.0, 4.0],
  );

  /// Bass Boost - enhanced low frequencies
  static const bassBoost = EqualizerPreset(
    id: 'bass_boost',
    name: 'Bass Boost',
    bands: [8.0, 5.0, 0.0, 0.0, 0.0],
  );

  /// Treble Boost - enhanced high frequencies
  static const trebleBoost = EqualizerPreset(
    id: 'treble_boost',
    name: 'Treble Boost',
    bands: [0.0, 0.0, 0.0, 5.0, 8.0],
  );

  /// Vocal - enhanced midrange for vocals
  static const vocal = EqualizerPreset(
    id: 'vocal',
    name: 'Vocal',
    bands: [-2.0, 0.0, 5.0, 3.0, 1.0],
  );

  /// Electronic - enhanced bass and treble
  static const electronic = EqualizerPreset(
    id: 'electronic',
    name: 'Electronic',
    bands: [7.0, 4.0, -1.0, 2.0, 6.0],
  );

  /// Hip Hop - enhanced bass
  static const hipHop = EqualizerPreset(
    id: 'hip_hop',
    name: 'Hip Hop',
    bands: [7.0, 4.0, 0.0, 1.0, 2.0],
  );

  /// List of all presets
  static const List<EqualizerPreset> all = [
    flat,
    rock,
    pop,
    jazz,
    classical,
    bassBoost,
    trebleBoost,
    vocal,
    electronic,
    hipHop,
  ];

  /// Get preset by ID
  static EqualizerPreset? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Frequency band information for display.
class EqualizerBand {
  /// Center frequency in Hz.
  final double frequency;

  /// Display label for the frequency.
  final String label;

  const EqualizerBand({
    required this.frequency,
    required this.label,
  });

  /// Standard equalizer bands.
  static const List<EqualizerBand> standard = [
    EqualizerBand(frequency: 60, label: '60Hz'),
    EqualizerBand(frequency: 230, label: '230Hz'),
    EqualizerBand(frequency: 910, label: '910Hz'),
    EqualizerBand(frequency: 3000, label: '3kHz'),
    EqualizerBand(frequency: 14000, label: '14kHz'),
  ];

  /// Alternative 10-band equalizer.
  static const List<EqualizerBand> tenBand = [
    EqualizerBand(frequency: 32, label: '32Hz'),
    EqualizerBand(frequency: 64, label: '64Hz'),
    EqualizerBand(frequency: 125, label: '125Hz'),
    EqualizerBand(frequency: 250, label: '250Hz'),
    EqualizerBand(frequency: 500, label: '500Hz'),
    EqualizerBand(frequency: 1000, label: '1kHz'),
    EqualizerBand(frequency: 2000, label: '2kHz'),
    EqualizerBand(frequency: 4000, label: '4kHz'),
    EqualizerBand(frequency: 8000, label: '8kHz'),
    EqualizerBand(frequency: 16000, label: '16kHz'),
  ];
}
