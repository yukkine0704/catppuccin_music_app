import 'package:dartz/dartz.dart';

import '../../domain/entities/equalizer_preset.dart';
import '../datasources/equalizer_service.dart';

/// Repository for managing equalizer settings.
class EqualizerRepository {
  final EqualizerService _service;

  EqualizerRepository(this._service);

  /// Gets all available presets.
  List<EqualizerPreset> getPresets() {
    return EqualizerPresets.all;
  }

  /// Gets the current equalizer state.
  Either<Exception, EqualizerPreset> getCurrentPreset() {
    try {
      return Right(_service.getCurrentPreset());
    } catch (e) {
      return Left(Exception('Failed to get current preset: $e'));
    }
  }

  /// Gets the enabled state.
  bool isEnabled() {
    return _service.getEnabled();
  }

  /// Saves the equalizer enabled state.
  Future<void> setEnabled(bool enabled) async {
    await _service.setEnabled(enabled);
  }

  /// Saves the selected preset.
  Future<void> setPreset(EqualizerPreset preset) async {
    await _service.setPresetId(preset.id);
    if (preset.id == 'custom') {
      await _service.setCustomBands(preset.bands);
    }
  }

  /// Saves custom band values.
  Future<void> setCustomBands(List<double> bands) async {
    await _service.setPresetId('custom');
    await _service.setCustomBands(bands);
  }

  /// Saves the full equalizer state.
  Future<void> saveState({
    required bool enabled,
    String? presetId,
    List<double>? customBands,
  }) async {
    await _service.saveEqualizerState(
      enabled: enabled,
      presetId: presetId,
      customBands: customBands,
    );
  }

  /// Resets to default state.
  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
  }
}
