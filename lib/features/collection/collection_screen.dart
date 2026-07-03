import 'package:flutter/material.dart';

import '../../widgets/saveroom_shell.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaveRoomShell(
      title: 'My Collection',
      children: [
        Text(
          'Collection backend comes in v12.4. For now this screen is UI-only.',
        ),
        ListTile(title: Text('Future: owned cards')),
        ListTile(title: Text('Future: wishlist')),
        ListTile(title: Text('Future: favourites')),
        ListTile(title: Text('Future: scan history')),
      ],
    );
  }
}
