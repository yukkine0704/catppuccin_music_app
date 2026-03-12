import 'package:catppuccin_flutter/catppuccin_flutter.dart'
    show Flavor, catppuccin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importaciones M3E según tu documentación
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../audio_player/presentation/providers/player_animation_provider.dart';
import '../providers/flavor_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      body: CustomScrollView(
        slivers: [
          // 1. Header Expressivo
          SliverAppBarM3E(
            variant: AppBarM3EVariant.large,
            titleText: 'Ajustes',
            pinned: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN APARIENCIA ---
                  _buildM3ESectionHeader('Apariencia', flavor),
                  _buildSettingsContainer(
                    flavor: flavor,
                    children: [
                      _buildSettingsTile(
                        title: 'Tema Visual',
                        subtitle: 'Selecciona tu paleta Catppuccin',
                        flavor: flavor,
                        trailing: _buildFlavorSelector(flavor),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildSettingsTile(
                        title: 'Modo Oscuro',
                        subtitle: 'Alternar entre luz y oscuridad',
                        flavor: flavor,
                        trailing: Switch(
                          value: _darkMode,
                          activeColor: flavor.mauve,
                          onChanged: (value) =>
                              setState(() => _darkMode = value),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN REPRODUCTOR ---
                  _buildM3ESectionHeader('Reproductor', flavor),
                  _buildSettingsContainer(
                    flavor: flavor,
                    children: [
                      _buildSettingsTile(
                        title: 'Animación',
                        subtitle: 'Estilo visual del disco',
                        flavor: flavor,
                        trailing: _buildAnimationSelector(flavor),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildSettingsTile(
                        title: 'Velocidad',
                        subtitle: '${_playbackSpeed.toStringAsFixed(1)}x',
                        flavor: flavor,
                        trailing: Slider(
                          value: _playbackSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 6,
                          activeColor: flavor.mauve,
                          onChanged: (v) => setState(() => _playbackSpeed = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botón de acción final tipo M3E
                  Center(
                    child: ButtonM3E(
                      label: const Text('Restablecer valores'),
                      icon: const Icon(Icons.restore_rounded),
                      style: ButtonM3EStyle.outlined,
                      size: ButtonM3ESize.md,
                      onPressed: () {
                        // Acción de reset
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header de sección con tipografía M3E
  Widget _buildM3ESectionHeader(String title, Flavor flavor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: flavor.mauve,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Contenedor que agrupa ajustes (Containment)
  Widget _buildSettingsContainer({
    required List<Widget> children,
    required Flavor flavor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: flavor.surface0,
        borderRadius: BorderRadius.circular(24), // Radio expresivo grande
        border: Border.all(color: flavor.surface1, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required Flavor flavor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: flavor.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: flavor.subtext1, fontSize: 13),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

Widget _buildFlavorSelector(Flavor currentFlavor) {
    return ButtonM3E(
      // Mostramos el nombre del sabor actual
      label: Text(_getFlavorName(currentFlavor)),
      style: ButtonM3EStyle.tonal,
      size: ButtonM3ESize.sm,
      onPressed: () {
        // 1. Definimos la lista de sabores disponibles
        final flavors = [
          catppuccin.latte,
          catppuccin.frappe,
          catppuccin.macchiato,
          catppuccin.mocha,
        ];

        // 2. Buscamos el índice actual y calculamos el siguiente
        final currentIndex = flavors.indexOf(currentFlavor);
        final nextIndex = (currentIndex + 1) % flavors.length;
        final nextFlavor = flavors[nextIndex];

        // 3. ¡IMPORTANTE! Actualizamos el provider
        // Asumiendo que tu flavorProvider tiene un notifier con un método setTheme o similar
        ref.read(flavorProvider.notifier).setFlavor(nextFlavor);

        // Si tu provider es un StateProvider simple, sería:
        // ref.read(flavorProvider.notifier).state = nextFlavor;
      },
    );
  }

  Widget _buildAnimationSelector(Flavor flavor) {
    final style = ref.watch(playerAnimationStyleProvider);
    return ButtonM3E(
      label: Text(style == PlayerAnimationStyle.vinyl ? 'Vinilo' : 'Simple'),
      style: ButtonM3EStyle.tonal,
      size: ButtonM3ESize.sm,
      onPressed: () {
        ref.read(playerAnimationStyleProvider.notifier).toggle();
      },
    );
  }

  String _getFlavorName(Flavor flavor) {
    if (flavor == catppuccin.latte) return 'Latte';
    if (flavor == catppuccin.frappe) return 'Frappé';
    if (flavor == catppuccin.macchiato) return 'Macchiato';
    return 'Mocha';
  }
}
