import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaveRoomShell(
      title: 'API / Settings',
      children: [
        SectionCard(
          title: 'App mode',
          icon: Icons.tune_outlined,
          children: [
            InfoTile(label: 'App version', value: AppConfig.appVersion),
            InfoTile(label: 'API baseline', value: AppConfig.apiBaseline),
            InfoTile(
              label: 'Fixture mode',
              value: AppConfig.fixtureMode ? 'enabled' : 'off',
            ),
            InfoTile(label: 'Real API mode', value: 'planned only'),
            InfoTile(label: 'Real API base URL', value: AppConfig.apiBaseUrl),
          ],
        ),
        SectionCard(
          title: 'Future backend milestones',
          icon: Icons.route_outlined,
          children: [
            InfoTile(label: 'Auth', value: 'planned v12.3'),
            InfoTile(label: 'Collection backend', value: 'planned v12.4'),
            InfoTile(label: 'Billing', value: 'planned v12.5'),
          ],
        ),
        SectionCard(
          title: 'Storage note',
          icon: Icons.storage_outlined,
          children: [
            Text(
              'App repo, Flutter SDK, package cache and Gradle cache are kept on /media/matt/Storage where controllable.',
            ),
          ],
        ),
      ],
    );
  }
}
