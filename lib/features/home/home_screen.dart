import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../config/app_config.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/saveroom_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'SaveRoom Scanner',
      children: [
        const InfoTile(label: 'SaveRoom Scanner API baseline', value: AppConfig.apiBaseline),
        const InfoTile(label: 'Mode', value: AppConfig.fixtureMode ? 'Fixture mode' : 'Real API mode'),
        _NavCard(title: 'Start Scanner', route: AppRoutes.scanner),
        _NavCard(title: 'View Mock Card Detail', route: AppRoutes.cardDetail),
        _NavCard(title: 'My Collection', route: AppRoutes.collection),
        _NavCard(title: 'API / Settings', route: AppRoutes.settings),
      ],
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
