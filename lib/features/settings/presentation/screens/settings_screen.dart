import 'package:catppuccin_flutter/catppuccin_flutter.dart'
    show Flavor, catppuccin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importaciones M3E según tu documentación
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../audio_player/presentation/providers/player_animation_provider.dart';
import '../../../equalizer/presentation/providers/equalizer_provider.dart';
import '../../../equalizer/presentation/screens/equalizer_screen.dart';
import '../../../library/presentation/providers/library_provider.dart';
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
                          activeThumbColor: flavor.mauve,
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

                  const SizedBox(height: 24),

                  // --- SECCIÓN AUDIO ---
                  _buildM3ESectionHeader('Audio', flavor),
                  _buildSettingsContainer(
                    flavor: flavor,
                    children: [
                      _buildSettingsTile(
                        title: 'Ecualizador',
                        subtitle: 'Ajustes de ecualización',
                        flavor: flavor,
                        trailing: IconButtonM3E(
                          variant: IconButtonM3EVariant.standard,
                          size: IconButtonM3ESize.sm,
                          icon: const Icon(Icons.equalizer),
                          onPressed: () =>
                              _navigateToEqualizer(context, ref, flavor),
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildCrossfadeTile(ref, flavor),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildGaplessTile(ref, flavor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN BIBLIOTECA ---
                  _buildM3ESectionHeader('Biblioteca', flavor),
                  _buildSettingsContainer(
                    flavor: flavor,
                    children: [
                      _buildSettingsTile(
                        title: 'Carpetas bloqueadas',
                        subtitle: 'Evitar que audios de apps aparezcan',
                        flavor: flavor,
                        trailing: IconButtonM3E(
                          variant: IconButtonM3EVariant.standard,
                          size: IconButtonM3ESize.sm,
                          icon: const Icon(Icons.folder_off_outlined),
                          onPressed: () =>
                              _showBlacklistDialog(context, ref, flavor),
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

  void _navigateToEqualizer(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
  ) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EqualizerScreen()));
  }

  Widget _buildCrossfadeTile(WidgetRef ref, Flavor flavor) {
    final crossfadeState = ref.watch(crossfadeProvider);

    return _buildSettingsTile(
      title: 'Crossfade',
      subtitle: crossfadeState.isEnabled
          ? '${crossfadeState.durationMs}ms'
          : 'Desactivado',
      flavor: flavor,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (crossfadeState.isEnabled)
            SizedBox(
              width: 100,
              child: Slider(
                value: crossfadeState.durationMs.toDouble(),
                min: 500,
                max: 8000,
                divisions: 15,
                activeColor: flavor.mauve,
                onChanged: (value) {
                  ref
                      .read(crossfadeProvider.notifier)
                      .setDuration(value.toInt());
                },
              ),
            ),
          Switch(
            value: crossfadeState.isEnabled,
            activeThumbColor: flavor.mauve,
            onChanged: (value) {
              ref.read(crossfadeProvider.notifier).setEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaplessTile(WidgetRef ref, Flavor flavor) {
    final gaplessState = ref.watch(gaplessProvider);

    return _buildSettingsTile(
      title: 'Gapless Playback',
      subtitle: gaplessState.isEnabled
          ? 'Reproducción continua'
          : 'Desactivado',
      flavor: flavor,
      trailing: Switch(
        value: gaplessState.isEnabled,
        activeThumbColor: flavor.mauve,
        onChanged: (value) {
          ref.read(gaplessProvider.notifier).setEnabled(value);
        },
      ),
    );
  }

  void _showBlacklistDialog(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
  ) {
    showDialog(
      context: context,
      builder: (context) => _BlacklistDialog(flavor: flavor),
    );
  }
}

/// Diálogo para gestionar la lista negra de carpetas
class _BlacklistDialog extends ConsumerWidget {
  final Flavor flavor;

  const _BlacklistDialog({required this.flavor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistState = ref.watch(blacklistProvider);

    return AlertDialog(
      backgroundColor: flavor.surface0,
      title: Row(
        children: [
          Icon(Icons.folder_off_outlined, color: flavor.mauve),
          const SizedBox(width: 12),
          Text('Carpetas bloqueadas', style: TextStyle(color: flavor.text)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Los audios de estas carpetas no aparecerán en la biblioteca.',
              style: TextStyle(color: flavor.subtext1, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: blacklistState.folders.length,
                itemBuilder: (context, index) {
                  final folder = blacklistState.folders[index];
                  return ListTile(
                    leading: Icon(Icons.folder_outlined, color: flavor.red),
                    title: Text(folder, style: TextStyle(color: flavor.text)),
                    trailing: IconButtonM3E(
                      variant: IconButtonM3EVariant.standard,
                      size: IconButtonM3ESize.sm,
                      icon: Icon(Icons.delete_outline, color: flavor.red),
                      onPressed: () {
                        ref
                            .read(blacklistProvider.notifier)
                            .removeFolder(folder);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        ButtonM3E(
          label: const Text('Añadir carpeta'),
          style: ButtonM3EStyle.tonal,
          size: ButtonM3ESize.sm,
          icon: const Icon(Icons.add),
          onPressed: () => _showAddFolderDialog(context, ref, flavor),
        ),
        ButtonM3E(
          label: const Text('Restablecer'),
          style: ButtonM3EStyle.outlined,
          size: ButtonM3ESize.sm,
          onPressed: () {
            ref.read(blacklistProvider.notifier).resetToDefaults();
          },
        ),
        ButtonM3E(
          label: const Text('Cerrar'),
          style: ButtonM3EStyle.filled,
          size: ButtonM3ESize.sm,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showAddFolderDialog(
    BuildContext context,
    WidgetRef ref,
    Flavor flavor,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: flavor.surface0,
        title: Text('Añadir carpeta', style: TextStyle(color: flavor.text)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: flavor.text),
          decoration: InputDecoration(
            hintText: 'Nombre de la carpeta',
            hintStyle: TextStyle(color: flavor.subtext1),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: flavor.surface1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: flavor.mauve),
            ),
          ),
        ),
        actions: [
          ButtonM3E(
            label: const Text('Cancelar'),
            style: ButtonM3EStyle.outlined,
            size: ButtonM3ESize.sm,
            onPressed: () => Navigator.of(context).pop(),
          ),
          ButtonM3E(
            label: const Text('Añadir'),
            style: ButtonM3EStyle.filled,
            size: ButtonM3ESize.sm,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(blacklistProvider.notifier).addFolder(controller.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
