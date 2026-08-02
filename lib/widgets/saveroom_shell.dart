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

// ponytail: smooth vertical graphite gradient only, no shapes or grid.
class _GraphiteBackdrop extends StatelessWidget {
  const _GraphiteBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF16171B), saveRoomBackground],
          ),
        ),
      ),
    );
  }
}
