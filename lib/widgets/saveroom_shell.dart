import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import 'glass_panel.dart';

class SaveRoomShell extends StatelessWidget {
  const SaveRoomShell({
    super.key,
    required this.title,
    required this.children,
    this.bottomBar,
    this.actions,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 10, 20, 34),
  });

  final String title;
  final List<Widget> children;
  final Widget? bottomBar;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: saveRoomBackground,
      extendBody: true,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: ColoredBox(
              color: saveRoomBackground.withValues(alpha: 0.62),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBackdrop()),
          SafeArea(
            top: false,
            child: ListView(padding: contentPadding, children: children),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: GlassPanel(
                strong: true,
                radius: 34,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: bottomBar!,
              ),
            ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF071416),
            saveRoomBackground,
            const Color(0xFF020303),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -80,
            child: _GlowBall(
              size: 260,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -120,
            child: _GlowBall(size: 240, color: saveRoomGold),
          ),
        ],
      ),
    );
  }
}

class _GlowBall extends StatelessWidget {
  const _GlowBall({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
