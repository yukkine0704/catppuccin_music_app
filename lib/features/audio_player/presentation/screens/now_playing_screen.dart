import 'dart:math' as math;

import 'package:button_group_m3e/button_group_m3e.dart'; // Asegúrate de tener la ruta correcta a tu ButtonGroupM3E
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/audio_player_provider.dart';

/// Now Playing screen with vinyl animation - M3E Redesigned version.
class NowPlayingScreen extends ConsumerStatefulWidget {
  final bool isInSheet;

  const NowPlayingScreen({super.key, this.isInSheet = false});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  // M3E States
  bool _isFavorite = false;
  bool _isShuffleEnabled = false;
  int _repeatMode = 0; // 0: off, 1: all, 2: one

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      body: SafeArea(
        child: widget.isInSheet
            ? _buildDraggableContent(flavor, playerState)
            : _buildStandardContent(flavor, playerState),
      ),
    );
  }

  Widget _buildDraggableContent(Flavor flavor, PlayerState playerState) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.of(context).pop();
        }
      },
      child: _buildContent(flavor, playerState),
    );
  }

  Widget _buildStandardContent(Flavor flavor, PlayerState playerState) {
    return _buildContent(flavor, playerState);
  }

  Widget _buildContent(Flavor flavor, PlayerState playerState) {
    return Column(
      children: [
        _buildCustomAppBar(flavor),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: _VinylWidget(
                isPlaying: playerState.isPlaying,
                albumArt: playerState.currentTrack?.albumArtBytes,
                flavor: flavor,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildMusicInfoRow(flavor),
        ),
        const SizedBox(height: 16),
        // Progress Section con Slider interactivo M3
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildProgressSection(playerState, flavor),
        ),
        const SizedBox(height: 16),
        // Control Panel con jerarquía y grupos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildControlPanel(playerState, flavor),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCustomAppBar(Flavor flavor) {
    final showCollapseButton = !widget.isInSheet;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showCollapseButton)
            // Variante Tonal para un fondo redondo sutil
            IconButtonM3E(
              variant: IconButtonM3EVariant.tonal,
              size: IconButtonM3ESize.md,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: flavor.text),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Collapse',
            )
          else
            const SizedBox(width: 48),

          Text(
            'Listening to',
            style: TextStyle(
              color: flavor.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Variante Tonal para hacer simetría visual
          IconButtonM3E(
            variant: IconButtonM3EVariant.tonal,
            size: IconButtonM3ESize.md,
            icon: Icon(Icons.queue_music_rounded, color: flavor.text),
            onPressed: () {},
            tooltip: 'Queue',
          ),
        ],
      ),
    );
  }

  Widget _buildMusicInfoRow(Flavor flavor) {
    final playerState = ref.watch(audioPlayerProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerState.currentTrack?.title ?? 'No hay canción',
                style: TextStyle(
                  color: flavor.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                playerState.currentTrack?.artist ?? 'Unknown Artist',
                style: TextStyle(color: flavor.subtext1, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButtonM3E(
          variant: IconButtonM3EVariant.standard,
          size: IconButtonM3ESize.lg,
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorite ? flavor.red : flavor.text,
          ),
          isSelected: _isFavorite,
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
          tooltip: 'Add to favorites',
        ),
      ],
    );
  }

  Widget _buildProgressSection(PlayerState state, Flavor flavor) {
    final position = state.position;
    final duration = state.duration.inMilliseconds > 0
        ? state.duration
        : const Duration(seconds: 1);

    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: flavor.mauve,
            inactiveTrackColor: flavor.surface1,
            thumbColor: flavor.mauve,
            overlayColor: flavor.mauve.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: progress,
            onChanged: (value) {
              final seekTo = Duration(
                milliseconds: (value * duration.inMilliseconds).toInt(),
              );
              ref.read(audioPlayerProvider.notifier).seek(seekTo);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: flavor.subtext1, fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: flavor.subtext1, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(PlayerState state, Flavor flavor) {
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Column(
      children: [
        // Controles Principales centrados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.lg,
              icon: Icon(
                Icons.skip_previous_rounded,
                color: flavor.text,
                size: 36,
              ),
              onPressed: () => notifier.skipToPrevious(),
            ),

            // Usamos IconButtonM3EVariant.filled para garantizar que el ripple quede perfectamente centrado
            IconButtonM3E(
              variant: IconButtonM3EVariant.filled,
              size: IconButtonM3ESize.lg,
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 40,
                color: flavor
                    .base, // Color de contraste para el icono sobre el fondo lleno
              ),
              onPressed: () => notifier.togglePlayPause(),
            ),

            IconButtonM3E(
              variant: IconButtonM3EVariant.standard,
              size: IconButtonM3ESize.lg,
              icon: Icon(Icons.skip_next_rounded, color: flavor.text, size: 36),
              onPressed: () => notifier.skipToNext(),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Fila Secundaria: ButtonGroupM3E estilo pill
        ButtonGroupM3E(
          type: ButtonGroupM3EType.connected,
          shape: ButtonGroupM3EShape.round,
          size: ButtonGroupM3ESize.sm,
          selection: true,
          style: ButtonM3EStyle.tonal,
          actions: [
            ButtonGroupM3EAction(
              label: Icon(
                Icons.shuffle_rounded,
                size: 22,
                color: _isShuffleEnabled ? flavor.mauve : flavor.subtext1,
              ),
              selected: _isShuffleEnabled,
              onPressed: () =>
                  setState(() => _isShuffleEnabled = !_isShuffleEnabled),
            ),
            ButtonGroupM3EAction(
              label: Icon(
                _repeatMode == 2
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                size: 22,
                color: _repeatMode > 0 ? flavor.mauve : flavor.subtext1,
              ),
              selected: _repeatMode > 0,
              onPressed: () =>
                  setState(() => _repeatMode = (_repeatMode + 1) % 3),
            ),
            ButtonGroupM3EAction(
              label: Icon(
                Icons.lyrics_rounded,
                size: 22,
                color: flavor.subtext1,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Animated vinyl widget (mantenido)
class _VinylWidget extends StatefulWidget {
  final bool isPlaying;
  final dynamic albumArt;
  final Flavor flavor;

  const _VinylWidget({
    required this.isPlaying,
    this.albumArt,
    required this.flavor,
  });

  @override
  State<_VinylWidget> createState() => _VinylWidgetState();
}

class _VinylWidgetState extends State<_VinylWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(_VinylWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: _buildVinyl(context),
      ),
    );
  }

  Widget _buildVinyl(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    final flavor = widget.flavor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: flavor.surface0,
        boxShadow: [
          BoxShadow(
            color: flavor.crust.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(10, (index) {
            final radius = size * 0.15 + (index * size * 0.06);
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: flavor.surface1.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            );
          }),
          Container(
            width: size * 0.42,
            height: size * 0.42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: flavor.mauve,
            ),
            child: ClipOval(
              child: widget.albumArt != null
                  ? Image.memory(widget.albumArt, fit: BoxFit.cover)
                  : Icon(
                      Icons.music_note_rounded,
                      color: flavor.crust,
                      size: size * 0.15,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
