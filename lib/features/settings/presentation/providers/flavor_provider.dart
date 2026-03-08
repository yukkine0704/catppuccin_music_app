import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that manages the selected Catppuccin flavor globally.
/// Uses SharedPreferences to persist the user's choice.
final flavorProvider = StateNotifierProvider<FlavorNotifier, Flavor>((ref) {
  return FlavorNotifier();
});

/// Helper to get SharedPreferences instance
final _prefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// StateNotifier that manages the selected flavor state.
class FlavorNotifier extends StateNotifier<Flavor> {
  FlavorNotifier() : super(catppuccin.mocha) {
    _loadFlavor();
  }

  Future<void> _loadFlavor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flavorIndex = prefs.getInt('flavorIndex') ?? 0;
      state = _getFlavorByIndex(flavorIndex);
    } catch (e) {
      // If loading fails, keep default mocha
    }
  }

  Flavor _getFlavorByIndex(int index) {
    switch (index) {
      case 0:
        return catppuccin.mocha;
      case 1:
        return catppuccin.latte;
      case 2:
        return catppuccin.frappe;
      case 3:
        return catppuccin.macchiato;
      default:
        return catppuccin.mocha;
    }
  }

  int _getFlavorIndex(Flavor flavor) {
    if (flavor == catppuccin.latte) return 1;
    if (flavor == catppuccin.frappe) return 2;
    if (flavor == catppuccin.macchiato) return 3;
    return 0;
  }

  /// Sets the flavor and persists it to SharedPreferences.
  Future<void> setFlavor(Flavor flavor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('flavorIndex', _getFlavorIndex(flavor));
      state = flavor;
    } catch (e) {
      // If saving fails, still update state
      state = flavor;
    }
  }
}
