import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/saveroom_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SaveRoomShell(
      title: 'API / Settings',
      children: [
        InfoTile(label: 'API baseline', value: AppConfig.apiBaseline),
        InfoTile(
          label: 'Fixture mode',
          value: AppConfig.fixtureMode ? 'default/on' : 'off',
        ),
        InfoTile(label: 'Real API mode', value: 'planned'),
        InfoTile(label: 'API base URL', value: AppConfig.apiBaseUrl),
        InfoTile(
          label: 'Auth',
          value: 'Mobile user login/session tokens planned for v12.3',
        ),
        InfoTile(
          label: 'Billing',
          value: 'Deferred until v12.5 paid beta readiness',
        ),
      ],
    );
  }
}
