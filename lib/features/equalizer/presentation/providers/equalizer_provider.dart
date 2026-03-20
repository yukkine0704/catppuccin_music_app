import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/equalizer_service.dart';
import '../../data/repositories/equalizer_repository_impl.dart';
import '../../domain/entities/equalizer_preset.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provider for EqualizerService.
final equalizerServiceProvider = Provider<EqualizerService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EqualizerService(prefs);
});

/// Provider for EqualizerRepository.
final equalizerRepositoryProvider = Provider<EqualizerRepository>((ref) {
  final service = ref.watch(equalizerServiceProvider);
  return EqualizerRepository(service);
});

/// State class for equalizer.
class EqualizerState {
  final bool isEnabled;
  final EqualizerPreset currentPreset;
  final List<EqualizerPreset> availablePresets;
  final bool isCustomBands;

  const EqualizerState({
    required this.isEnabled,
    required this.currentPreset,
    required this.availablePresets,
    required this.isCustomBands,
  });

  EqualizerState copyWith({
    bool? isEnabled,
    EqualizerPreset? currentPreset,
    List<EqualizerPreset>? availablePresets,
    bool? isCustomBands,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      currentPreset: currentPreset ?? this.currentPreset,
      availablePresets: availablePresets ?? this.availablePresets,
      isCustomBands: isCustomBands ?? this.isCustomBands,
    );
  }
}

/// Notifier for managing equalizer state.
class EqualizerNotifier extends StateNotifier<EqualizerState> {
  final EqualizerRepository _repository;

  EqualizerNotifier(this._repository)
      : super(EqualizerState(
          isEnabled: _repository.isEnabled(),
          currentPreset: _repository.getCurrentPreset().fold(
                (e) => EqualizerPresets.flat,
                (preset) => preset,
              ),
          availablePresets: _repository.getPresets(),
          isCustomBands: _repository.getCurrentPreset().fold(
                (e) => false,
                (preset) => preset.id == 'custom',
              ),
        ));

  /// Toggles the equalizer on/off.
  Future<void> toggleEnabled() async {
    final newEnabled = !state.isEnabled;
    await _repository.setEnabled(newEnabled);
    state = state.copyWith(
      isEnabled: newEnabled,
      currentPreset: state.currentPreset.copyWith(isEnabled: newEnabled),
    );
  }

  /// Sets the equalizer enabled state.
  Future<void> setEnabled(bool enabled) async {
    await _repository.setEnabled(enabled);
    state = state.copyWith(
      isEnabled: enabled,
      currentPreset: state.currentPreset.copyWith(isEnabled: enabled),
    );
  }

  /// Selects a preset.
  Future<void> selectPreset(EqualizerPreset preset) async {
    await _repository.setPreset(preset);
    state = state.copyWith(
      currentPreset: preset,
      isCustomBands: preset.id == 'custom',
    );
  }

  /// Updates custom band values.
  Future<void> updateCustomBands(List<double> bands) async {
    final customPreset = EqualizerPreset(
      id: 'custom',
      name: 'Custom',
      bands: bands,
      isEnabled: state.isEnabled,
    );
    await _repository.setCustomBands(bands);
    state = state.copyWith(
      currentPreset: customPreset,
      isCustomBands: true,
    );
  }

  /// Updates a single band value.
  Future<void> updateBand(int index, double value) async {
    final bands = List<double>.from(state.currentPreset.bands);
    if (index >= 0 && index < bands.length) {
      bands[index] = value;
      await updateCustomBands(bands);
    }
  }

  /// Resets to default (flat, disabled).
  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    state = EqualizerState(
      isEnabled: false,
      currentPreset: EqualizerPresets.flat,
      availablePresets: _repository.getPresets(),
      isCustomBands: false,
    );
  }
}

/// Provider for EqualizerNotifier.
final equalizerProvider =
    StateNotifierProvider<EqualizerNotifier, EqualizerState>((ref) {
  final repository = ref.watch(equalizerRepositoryProvider);
  return EqualizerNotifier(repository);
});

/// Provider for crossfade settings.
class CrossfadeState {
  final bool isEnabled;
  final int durationMs;

  const CrossfadeState({
    required this.isEnabled,
    required this.durationMs,
  });

  CrossfadeState copyWith({
    bool? isEnabled,
    int? durationMs,
  }) {
    return CrossfadeState(
      isEnabled: isEnabled ?? this.isEnabled,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

/// Notifier for managing crossfade state.
class CrossfadeNotifier extends StateNotifier<CrossfadeState> {
  final SharedPreferences _prefs;

  static const String _enabledKey = 'crossfade_enabled';
  static const String _durationKey = 'crossfade_duration';

  CrossfadeNotifier(this._prefs)
      : super(CrossfadeState(
          isEnabled: _prefs.getBool(_enabledKey) ?? false,
          durationMs: _prefs.getInt(_durationKey) ?? 3000,
        ));

  /// Toggles crossfade on/off.
  Future<void> toggleEnabled() async {
    final newEnabled = !state.isEnabled;
    await _prefs.setBool(_enabledKey, newEnabled);
    state = state.copyWith(isEnabled: newEnabled);
  }

  /// Sets crossfade enabled state.
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  /// Sets crossfade duration.
  Future<void> setDuration(int durationMs) async {
    await _prefs.setInt(_durationKey, durationMs);
    state = state.copyWith(durationMs: durationMs);
  }
}

/// Provider for CrossfadeNotifier.
final crossfadeProvider =
    StateNotifierProvider<CrossfadeNotifier, CrossfadeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CrossfadeNotifier(prefs);
});

/// Provider for gapless playback settings.
class GaplessState {
  final bool isEnabled;

  const GaplessState({required this.isEnabled});

  GaplessState copyWith({bool? isEnabled}) {
    return GaplessState(isEnabled: isEnabled ?? this.isEnabled);
  }
}

/// Notifier for managing gapless playback state.
class GaplessNotifier extends StateNotifier<GaplessState> {
  final SharedPreferences _prefs;

  static const String _enabledKey = 'gapless_enabled';

  GaplessNotifier(this._prefs)
      : super(GaplessState(
          isEnabled: _prefs.getBool(_enabledKey) ?? true, // Default to enabled
        ));

  /// Toggles gapless playback on/off.
  Future<void> toggleEnabled() async {
    final newEnabled = !state.isEnabled;
    await _prefs.setBool(_enabledKey, newEnabled);
    state = state.copyWith(isEnabled: newEnabled);
  }

  /// Sets gapless playback enabled state.
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
    state = state.copyWith(isEnabled: enabled);
  }
}

/// Provider for GaplessNotifier.
final gaplessProvider =
    StateNotifierProvider<GaplessNotifier, GaplessState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GaplessNotifier(prefs);
});
