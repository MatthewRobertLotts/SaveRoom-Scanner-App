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
    this.contentPadding = const EdgeInsets.fromLTRB(16, 8, 16, 28),
  });

  final String title;
  final List<Widget> children;
  final Widget? bottomBar;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: ColoredBox(
              color: saveRoomBackground.withValues(alpha: 0.72),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _GraphiteBackdrop()),
          SafeArea(
            top: false,
            child: ListView(padding: contentPadding, children: children),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: GlassPanel(
                strong: true,
                radius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: bottomBar!,
              ),
            ),
    );
  }
}

class _GraphiteBackdrop extends StatelessWidget {
  const _GraphiteBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: saveRoomBackground,
          gradient: RadialGradient(
            center: Alignment(-0.9, -0.72),
            radius: 1.35,
            colors: [Color(0xFF302017), saveRoomBackground],
            stops: [0, 0.72],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -110,
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      saveRoomOrange.withValues(alpha: 0.22),
                      saveRoomOrange.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -150,
              bottom: 30,
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: 430,
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [
                        saveRoomOrange.withValues(alpha: 0),
                        saveRoomOrange.withValues(alpha: 0.08),
                        saveRoomOrange.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..strokeWidth = 1;
    const spacing = 46.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
