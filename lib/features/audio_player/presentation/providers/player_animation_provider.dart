import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Animation style for the player screen
enum PlayerAnimationStyle {
  vinyl,  // Rotating vinyl record
  simple, // Simple album art
}

/// Provider for managing player animation style preference
class PlayerAnimationStyleNotifier extends StateNotifier<PlayerAnimationStyle> {
  static const String _key = 'playerAnimationStyle';

  PlayerAnimationStyleNotifier() : super(PlayerAnimationStyle.simple) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'vinyl') {
      state = PlayerAnimationStyle.vinyl;
    } else {
      state = PlayerAnimationStyle.simple;
    }
  }

  Future<void> setStyle(PlayerAnimationStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, style == PlayerAnimationStyle.vinyl ? 'vinyl' : 'simple');
    state = style;
  }

  Future<void> toggle() async {
    final newStyle = state == PlayerAnimationStyle.vinyl
        ? PlayerAnimationStyle.simple
        : PlayerAnimationStyle.vinyl;
    await setStyle(newStyle);
  }
}

/// Provider for player animation style
final playerAnimationStyleProvider =
    StateNotifierProvider<PlayerAnimationStyleNotifier, PlayerAnimationStyle>(
  (ref) => PlayerAnimationStyleNotifier(),
);
