import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 12,
    this.strong = false,
    this.accent = false,
    this.onTap,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final bool strong;
  final bool accent;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = context.saveRoomTokens;
    final borderRadius = BorderRadius.circular(radius);
    final top = strong ? saveRoomRaisedSurface : saveRoomSurface;
    final bottom = strong ? saveRoomSurface : const Color(0xFF101010);
    final borderColor = accent
        ? colors.primary.withValues(alpha: 0.48)
        : tokens.glassBorder;

    Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        color: strong ? top : bottom,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (shadow) {
      panel = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            if (accent)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: panel,
      );
    }

    return Padding(padding: margin, child: panel);
  }
}
