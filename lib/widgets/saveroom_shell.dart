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
        flexibleSpace: const ColoredBox(color: saveRoomBackground),
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
  Widget build(BuildContext context) =>
      const ColoredBox(color: saveRoomBackground);
}
