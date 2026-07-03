import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../services/fixture_loader.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/saveroom_shell.dart';

class MockScanResultScreen extends StatelessWidget {
  const MockScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: const FixtureLoader().loadCardDetail(),
      builder: (context, snapshot) {
        final body = snapshot.hasData
            ? _loaded(context, snapshot.data!)
            : _loading(snapshot);
        return SaveRoomShell(title: 'Mock scan result', children: body);
      },
    );
  }

  List<Widget> _loaded(BuildContext context, Map<String, dynamic> fixture) {
    final data = asMap(fixture['data']);
    final card = asMap(data['card']);
    return [
      InfoTile(label: 'Matched card', value: textAt(card, 'name')),
      const InfoTile(label: 'Confidence', value: 'Mock / fixture only'),
      FilledButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cardDetail),
        child: const Text('View card detail'),
      ),
      const SizedBox(height: 8),
      const FilledButton(
        onPressed: null,
        child: Text('Add to collection — planned v12.4'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Rescan'),
      ),
    ];
  }

  List<Widget> _loading(AsyncSnapshot<Map<String, dynamic>> snapshot) => [
        if (snapshot.hasError)
          Text('Fixture load failed: ${snapshot.error}')
        else
          const LinearProgressIndicator(),
      ];
}
