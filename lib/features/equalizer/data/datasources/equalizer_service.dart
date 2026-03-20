import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/equalizer_preset.dart';

/// Service for managing equalizer settings.
/// Handles persistence and application of equalizer presets.
class EqualizerService {
  final SharedPreferences _prefs;

  // SharedPreferences keys
  static const String _enabledKey = 'equalizer_enabled';
  static const String _presetIdKey = 'equalizer_preset_id';
  static const String _bandsKey = 'equalizer_bands';
  static const String _customBandsKey = 'equalizer_custom_bands';

  EqualizerService(this._prefs);

  /// Gets the equalizer enabled state from storage.
  bool getEnabled() {
    return _prefs.getBool(_enabledKey) ?? false;
  }

  /// Saves the equalizer enabled state.
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
    debugPrint('[EqualizerService] Equalizer enabled: $enabled');
  }

  /// Gets the saved preset ID.
  String? getPresetId() {
    return _prefs.getString(_presetIdKey);
  }

  /// Saves the preset ID.
  Future<void> setPresetId(String? presetId) async {
    if (presetId != null) {
      await _prefs.setString(_presetIdKey, presetId);
    } else {
      await _prefs.remove(_presetIdKey);
    }
    debugPrint('[EqualizerService] Preset ID saved: $presetId');
  }

  /// Gets the custom bands (when not using a preset).
  List<double> getCustomBands() {
    final bandsString = _prefs.getString(_customBandsKey);
    if (bandsString != null) {
      try {
        return bandsString.split(',').map((e) => double.parse(e)).toList();
      } catch (_) {
        return [0.0, 0.0, 0.0, 0.0, 0.0];
      }
    }
    return [0.0, 0.0, 0.0, 0.0, 0.0];
  }

  /// Saves custom band values.
  Future<void> setCustomBands(List<double> bands) async {
    final bandsString = bands.join(',');
    await _prefs.setString(_customBandsKey, bandsString);
    debugPrint('[EqualizerService] Custom bands saved: $bands');
  }

  /// Gets the current preset (or custom bands if no preset selected).
  EqualizerPreset getCurrentPreset() {
    final presetId = getPresetId();
    if (presetId != null) {
      final preset = EqualizerPresets.getById(presetId);
      if (preset != null) {
        return preset.copyWith(isEnabled: getEnabled());
      }
    }

    // Return custom bands as a custom preset
    final bands = getCustomBands();
    return EqualizerPreset(
      id: 'custom',
      name: 'Custom',
      bands: bands,
      isEnabled: getEnabled(),
    );
  }

  /// Saves the current equalizer state.
  Future<void> saveEqualizerState({
    required bool enabled,
    String? presetId,
    List<double>? customBands,
  }) async {
    await setEnabled(enabled);
    if (presetId != null) {
      await setPresetId(presetId);
    }
    if (customBands != null) {
      await setCustomBands(customBands);
    }
  }

  /// Resets equalizer to default (flat, disabled).
  Future<void> resetToDefaults() async {
    await _prefs.remove(_enabledKey);
    await _prefs.remove(_presetIdKey);
    await _prefs.remove(_customBandsKey);
    debugPrint('[EqualizerService] Reset to defaults');
  }
}
