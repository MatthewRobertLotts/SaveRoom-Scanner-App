import 'package:flutter/material.dart';

class SaveRoomShell extends StatelessWidget {
  const SaveRoomShell({
    super.key,
    required this.title,
    required this.children,
    this.bottomBar,
  });

  final String title;
  final List<Widget> children;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: bottomBar!,
            ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomBar == null ? 24 : 12),
          children: children,
        ),
      ),
    );
  }
}
