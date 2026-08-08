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
    this.contentPadding = const EdgeInsets.fromLTRB(18, 8, 18, 28),
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
      appBar: AppBar(title: Text(title), actions: actions),
      body: Stack(
        children: [
          const Positioned.fill(child: _OpalBackdrop()),
          SafeArea(
            top: false,
            child: ListView(padding: contentPadding, children: children),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: GlassPanel(
                strong: true,
                radius: 28,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: bottomBar!,
              ),
            ),
    );
  }
}

class _OpalBackdrop extends StatelessWidget {
  const _OpalBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.7, -0.95),
          radius: 1.15,
          colors: [
            saveRoomPrimary.withValues(alpha: 0.16),
            saveRoomBackground,
            saveRoomBackground,
          ],
          stops: const [0, 0.44, 1],
        ),
      ),
    );
  }
}
