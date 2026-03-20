import 'package:catppuccin_flutter/catppuccin_flutter.dart' show Flavor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../../domain/entities/equalizer_preset.dart';
import '../providers/equalizer_provider.dart';

/// Equalizer screen with 5-band EQ and presets.
class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final equalizerState = ref.watch(equalizerProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBarM3E(
            variant: AppBarM3EVariant.large,
            titleText: 'Ecualizador',
            pinned: true,
            leading: IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButtonM3E(
                variant: IconButtonM3EVariant.standard,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(equalizerProvider.notifier).resetToDefaults();
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable/Disable Toggle
                  _buildEnableSection(flavor, equalizerState, ref),

                  const SizedBox(height: 24),

                  // Presets Section
                  _buildPresetsSection(flavor, equalizerState, ref),

                  const SizedBox(height: 24),

                  // Equalizer Bands
                  _buildBandsSection(flavor, equalizerState, ref),

                  const SizedBox(height: 16),

                  // Band Values Display
                  _buildBandValues(flavor, equalizerState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSection(
    Flavor flavor,
    EqualizerState state,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: flavor.surface0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: flavor.surface1, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            state.isEnabled ? Icons.graphic_eq : Icons.graphic_eq_outlined,
            color: state.isEnabled ? flavor.mauve : flavor.subtext1,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ecualizador',
                  style: TextStyle(
                    color: flavor.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  state.isEnabled ? 'Activo' : 'Inactivo',
                  style: TextStyle(color: flavor.subtext1, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: state.isEnabled,
            activeThumbColor: flavor.mauve,
            onChanged: (value) {
              ref.read(equalizerProvider.notifier).setEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection(
    Flavor flavor,
    EqualizerState state,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'PRESETS',
            style: TextStyle(
              color: flavor.mauve,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.availablePresets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final preset = state.availablePresets[index];
              final isSelected =
                  state.currentPreset.id == preset.id ||
                  (state.isCustomBands &&
                      preset.id == 'custom' &&
                      state.currentPreset.id == 'custom');

              return ButtonM3E(
                label: Text(preset.name),
                style: isSelected
                    ? ButtonM3EStyle.filled
                    : ButtonM3EStyle.tonal,
                size: ButtonM3ESize.sm,
                onPressed: state.isEnabled
                    ? () {
                        ref
                            .read(equalizerProvider.notifier)
                            .selectPreset(preset);
                      }
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBandsSection(
    Flavor flavor,
    EqualizerState state,
    WidgetRef ref,
  ) {
    final bands = EqualizerBand.standard;
    final currentBands = state.currentPreset.bands;

    return Container(
      decoration: BoxDecoration(
        color: flavor.surface0,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: flavor.surface1, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'BANDAS',
            style: TextStyle(
              color: flavor.mauve,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(bands.length, (index) {
                return _buildBandSlider(
                  flavor: flavor,
                  label: bands[index].label,
                  value: currentBands[index],
                  isEnabled: state.isEnabled,
                  onChanged: state.isEnabled
                      ? (value) {
                          ref
                              .read(equalizerProvider.notifier)
                              .updateBand(index, value);
                        }
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandSlider({
    required Flavor flavor,
    required String label,
    required double value,
    required bool isEnabled,
    ValueChanged<double>? onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('+12', style: TextStyle(color: flavor.subtext1, fontSize: 10)),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: value,
              min: -12.0,
              max: 12.0,
              divisions: 24,
              activeColor: isEnabled ? flavor.mauve : flavor.surface1,
              inactiveColor: flavor.surface1,
              onChanged: onChanged,
            ),
          ),
        ),
        Text('-12', style: TextStyle(color: flavor.subtext1, fontSize: 10)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: flavor.text,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBandValues(Flavor flavor, EqualizerState state) {
    final bands = state.currentPreset.bands;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: bands.map((value) {
        final dbValue = value.toStringAsFixed(1);
        final sign = value >= 0 ? '+' : '';
        return Text(
          '$sign${dbValue}dB',
          style: TextStyle(
            color: flavor.subtext1,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        );
      }).toList(),
    );
  }
}
