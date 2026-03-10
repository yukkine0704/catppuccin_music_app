import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/repositories/settings_repository.dart';

/// Provider for SettingsRepository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return getIt<SettingsRepository>();
});

/// Provider that manages the selected Catppuccin flavor globally.
/// Uses SettingsRepository to persist the user's choice.
final flavorProvider = StateNotifierProvider<FlavorNotifier, Flavor>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return FlavorNotifier(repository);
});

/// StateNotifier that manages the selected flavor state.
class FlavorNotifier extends StateNotifier<Flavor> {
  final SettingsRepository _repository;

  FlavorNotifier(this._repository) : super(catppuccin.mocha) {
    _loadFlavor();
  }

  Future<void> _loadFlavor() async {
    final result = _repository.getFlavor();

    result.fold(
      (failure) {
        // If loading fails, keep default mocha
      },
      (flavor) {
        state = flavor;
      },
    );
  }

  /// Sets the flavor and persists it to storage.
  Future<void> setFlavor(Flavor flavor) async {
    final result = _repository.setFlavor(flavor);

    result.fold(
      (failure) {
        // If saving fails, still update state
        state = flavor;
      },
      (_) {
        state = flavor;
      },
    );
  }
}
