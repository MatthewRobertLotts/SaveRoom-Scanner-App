import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 28,
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
    final bottom = strong ? const Color(0xFF071314) : const Color(0xFF090D10);
    final borderColor = accent
        ? colors.primary.withValues(alpha: 0.48)
        : tokens.glassBorder;

    Widget panel = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                top.withValues(alpha: 0.92),
                bottom.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 0.9,
                            colors: [
                              colors.primary.withValues(
                                alpha: accent ? 0.18 : 0.06,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
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
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
            if (accent)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.14),
                blurRadius: 34,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: panel,
      );
    }

    return Padding(padding: margin, child: panel);
  }
}
