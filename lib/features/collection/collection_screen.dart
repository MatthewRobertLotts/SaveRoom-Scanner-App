import 'package:flutter/material.dart';

import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaveRoomShell(
      title: 'My Collection',
      children: [
        Text(
          'My Collection',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'UI-only placeholder. No local database, sync, or collection backend yet.',
        ),
        SectionCard(
          title: 'Mock stats',
          icon: Icons.inventory_2_outlined,
          children: [
            _Stat('Owned cards', '0'),
            _Stat('Wishlist', '0'),
            _Stat('Scanned today', '0'),
          ],
        ),
        SectionCard(
          title: 'Planned v12.4 backend',
          icon: Icons.rocket_launch_outlined,
          children: [
            Text('• owned cards'),
            Text('• wishlist'),
            Text('• favourites'),
            Text('• scan history'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(
      value,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
