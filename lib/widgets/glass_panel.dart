import 'package:flutter/material.dart';

import '../app/app_theme.dart';

// ponytail: flat solid card with border — no blur, no glow, no gradients.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 24,
    this.strong = false,
    this.accent = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final bool strong;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saveRoomTokens;
    final borderRadius = BorderRadius.circular(radius);
    final borderColor = accent
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.55)
        : tokens.glassBorder;

    final panel = ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: strong ? tokens.glassStrong : tokens.glassFill,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? Padding(padding: padding, child: child)
              : InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  child: Padding(padding: padding, child: child),
                ),
        ),
      ),
    );

    return Padding(padding: margin, child: panel);
  }
}
