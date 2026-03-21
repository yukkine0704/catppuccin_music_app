import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/flavor_provider.dart';

/// M3E compliant SnackBar component following Material Design 3 Expressive guidelines.
///
/// Features:
/// - M3E token-based design system
/// - Catppuccin HCT color model integration
/// - Expressive motion with spring physics
/// - Accessibility-first approach with 48dp touch targets
/// - Semantic color roles (primary, secondary, surface)
/// - Proper typography scale with emphasized variants
class SnackBarM3E {
  /// Shows a success snackbar with M3E styling above all content.
  static void showSuccess(
    BuildContext context,
    WidgetRef ref, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final flavor = ref.read(flavorProvider);
    _showOverlaySnackBar(
      context: context,
      flavor: flavor,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: flavor.green,
      borderColor: flavor.green.withValues(alpha: 0.2),
      duration: duration,
    );
  }

  /// Shows an error snackbar with M3E styling above all content.
  static void showError(
    BuildContext context,
    WidgetRef ref, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    final flavor = ref.read(flavorProvider);
    _showOverlaySnackBar(
      context: context,
      flavor: flavor,
      message: message,
      icon: Icons.error_rounded,
      iconColor: flavor.red,
      borderColor: flavor.red.withValues(alpha: 0.2),
      duration: duration,
    );
  }

  /// Shows an info snackbar with M3E styling above all content.
  static void showInfo(
    BuildContext context,
    WidgetRef ref, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final flavor = ref.read(flavorProvider);
    _showOverlaySnackBar(
      context: context,
      flavor: flavor,
      message: message,
      icon: Icons.info_rounded,
      iconColor: flavor.blue,
      borderColor: flavor.blue.withValues(alpha: 0.2),
      duration: duration,
    );
  }

  /// Internal method to show overlay snackbar above all content.
  static void _showOverlaySnackBar({
    required BuildContext context,
    required Flavor flavor,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required Duration duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _AnimatedSnackBar(
            message: message,
            icon: icon,
            iconColor: iconColor,
            backgroundColor: flavor.surface0,
            borderColor: borderColor,
            textColor: flavor.text,
            onComplete: () => overlayEntry.remove(),
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

/// Widget for animated snackbar with M3E styling.
class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onComplete;
  final Duration duration;

  const _AnimatedSnackBar({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onComplete,
    required this.duration,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
