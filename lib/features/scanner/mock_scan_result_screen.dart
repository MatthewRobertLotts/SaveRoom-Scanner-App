import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../services/fixture_loader.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class MockScanResultScreen extends StatelessWidget {
  const MockScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: const FixtureLoader().loadCardDetail(),
      builder: (context, snapshot) => SaveRoomShell(
        title: 'Mock scan result',
        children: snapshot.hasData
            ? _loaded(context, snapshot.data!)
            : _loading(snapshot),
      ),
    );
  }

  List<Widget> _loaded(BuildContext context, Map<String, dynamic> fixture) {
    final data = asMap(fixture['data']);
    final card = asMap(data['card']);
    final set = asMap(data['set']);
    final setText = joinPresent([
      textAt(set, 'name'),
      textAt(set, 'set_code'),
      textAt(card, 'collector_number'),
    ]);
    return [
      const FixtureBadge(),
      const SizedBox(height: 12),
      SectionCard(
        title: textAt(card, 'name', 'Matched card'),
        icon: Icons.auto_awesome_outlined,
        children: [
          const InfoTile(
            label: 'Confidence',
            value: 'Mock / fixture only',
            icon: Icons.speed_outlined,
          ),
          InfoTile(
            label: 'Set / code / number',
            value: setText,
            icon: Icons.style_outlined,
          ),
          InfoTile(
            label: 'Language',
            value: textAt(card, 'language_code'),
            icon: Icons.language_outlined,
          ),
        ],
      ),
      FilledButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cardDetail),
        child: const Text('View card detail'),
      ),
      const SizedBox(height: 8),
      const FilledButton(
        onPressed: null,
        child: Text('Add to collection — coming in v12.4'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Scan again'),
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
