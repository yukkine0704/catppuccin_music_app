import 'package:catppuccin_flutter/catppuccin_flutter.dart'
    show Flavor, catppuccin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/flavor_provider.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? true;
      _playbackSpeed = prefs.getDouble('playbackSpeed') ?? 1.0;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  Future<void> _savePlaybackSpeed(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('playbackSpeed', value);
    setState(() {
      _playbackSpeed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the flavor provider to rebuild when theme changes globally
    final flavor = ref.watch(flavorProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBarM3E(
        titleText: 'Ajustes',
        backgroundColor: flavor.crust.withValues(alpha: 0.8),
        foregroundColor: flavor.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionHeader('Apariencia', flavor),
          _buildSettingsTile(
            title: 'Sabor de Catppuccin',
            subtitle: _getFlavorName(flavor),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: flavor.surface1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<Flavor>(
                value: flavor,
                dropdownColor: flavor.surface1,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: flavor.text),
                style: TextStyle(color: flavor.text, fontSize: 14),
                items: [
                  DropdownMenuItem(
                    value: catppuccin.mocha,
                    child: Text('Mocha', style: TextStyle(color: flavor.text)),
                  ),
                  DropdownMenuItem(
                    value: catppuccin.latte,
                    child: Text('Latte', style: TextStyle(color: flavor.text)),
                  ),
                  DropdownMenuItem(
                    value: catppuccin.frappe,
                    child: Text('Frappé', style: TextStyle(color: flavor.text)),
                  ),
                  DropdownMenuItem(
                    value: catppuccin.macchiato,
                    child: Text(
                      'Macchiato',
                      style: TextStyle(color: flavor.text),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(flavorProvider.notifier).setFlavor(value);
                  }
                },
              ),
            ),
            flavor: flavor,
          ),
          _buildSettingsTile(
            title: 'Modo Oscuro',
            subtitle: 'Usar tema oscuro de Catppuccin',
            trailing: Switch(
              value: _darkMode,
              activeThumbColor: flavor.mauve,
              onChanged: _saveDarkMode,
            ),
            flavor: flavor,
          ),

          const SizedBox(height: 24),

          // Playback section
          _buildSectionHeader('Reproducción', flavor),
          _buildSettingsTile(
            title: 'Velocidad de reproducción',
            subtitle: '${_playbackSpeed}x',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _playbackSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                activeColor: flavor.mauve,
                inactiveColor: flavor.surface1,
                onChanged: _savePlaybackSpeed,
              ),
            ),
            flavor: flavor,
          ),

          const SizedBox(height: 24),

          // About section
          _buildSectionHeader('Acerca de', flavor),
          _buildSettingsTile(
            title: 'The Vinyl Sanctuary',
            subtitle: 'Versión 1.0.0',
            trailing: Icon(Icons.music_note_rounded, color: flavor.mauve),
            flavor: flavor,
          ),
          _buildSettingsTile(
            title: 'Diseñado con',
            subtitle: 'Flutter, Catppuccin & M3E',
            trailing: Icon(Icons.code_rounded, color: flavor.blue),
            flavor: flavor,
          ),
        ],
      ),
    );
  }

  String _getFlavorName(Flavor flavor) {
    if (flavor == catppuccin.latte) return 'Latte';
    if (flavor == catppuccin.frappe) return 'Frappé';
    if (flavor == catppuccin.macchiato) return 'Macchiato';
    return 'Mocha';
  }

  Widget _buildSectionHeader(String title, Flavor flavor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: flavor.mauve,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required Flavor flavor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: flavor.surface0,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: flavor.text, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: flavor.subtext1)),
        trailing: trailing,
      ),
    );
  }
}
