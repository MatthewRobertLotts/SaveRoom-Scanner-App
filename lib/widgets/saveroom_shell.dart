import 'package:flutter/material.dart';

class SaveRoomShell extends StatelessWidget {
  const SaveRoomShell({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: children),
      ),
    );
  }
}
