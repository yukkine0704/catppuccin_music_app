import 'dart:math' as math;
import 'dart:typed_data';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

/// Vinyl animation widget that displays a rotating vinyl record with album art in the center.
class VinylAnimation extends StatefulWidget {
  final Uint8List? albumArt;
  final Flavor flavor;
  final double size;
  final double borderRadius;
  final bool isPlaying;

  const VinylAnimation({
    super.key,
    required this.albumArt,
    required this.flavor,
    required this.size,
    required this.borderRadius,
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
      duration: const Duration(seconds: 3),
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
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinyl background
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.flavor.crust,
              boxShadow: [
                BoxShadow(
                  color: widget.flavor.crust.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Vinyl grooves
          Container(
            width: widget.size * 0.85,
            height: widget.size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          Container(
            width: widget.size * 0.55,
            height: widget.size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.flavor.subtext0.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          // Album art center
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.albumArt != null && widget.albumArt!.isNotEmpty
                ? Image.memory(
                    widget.albumArt!,
                    width: widget.size * 0.45,
                    height: widget.size * 0.45,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size * 0.45,
      height: widget.size * 0.45,
      decoration: BoxDecoration(
        color: widget.flavor.surface0,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: widget.flavor.subtext0,
        size: widget.size * 0.2,
      ),
    );
  }
}
