import 'dart:typed_data';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

class VinylAnimation extends StatefulWidget {
  final Uint8List? albumArt;
  final Flavor flavor;
  final double size;
  final bool isPlaying;

  const VinylAnimation({
    super.key,
    required this.albumArt,
    required this.flavor,
    required this.size,
    required this.isPlaying,
  });

  @override
  State<VinylAnimation> createState() => _VinylAnimationState();
}

class _VinylAnimationState extends State<VinylAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Rotación elegante
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VinylAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.flavor.crust, // Color base del disco
          boxShadow: [
            BoxShadow(
              // USAMOS EL COLOR DEL FLAVOR PARA LA SOMBRA
              color: widget.flavor.overlay2.withValues(alpha: 1),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8), // Sombra ligeramente hacia abajo
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Surcos decorativos
            ...List.generate(4, (index) {
              final double ringSize = widget.size * (0.6 + (index * 0.1));
              return Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.flavor.overlay0.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              );
            }),

            // Imagen del álbum circular
            Container(
              width: widget.size * 0.45,
              height: widget.size * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.flavor.surface0,
                border: Border.all(
                  color: widget.flavor.crust, width: 2),
              ),
              child: ClipOval(
                child: widget.albumArt != null && widget.albumArt!.isNotEmpty
                    ? Image.memory(
                        widget.albumArt!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            // Agujero central
            Container(
              width: widget.size * 0.03,
              height: widget.size * 0.03,
              decoration: BoxDecoration(
                color: widget.flavor.crust,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: widget.flavor.surface0,
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.mauve,
        size: widget.size * 0.2,
      ),
    );
  }
}
