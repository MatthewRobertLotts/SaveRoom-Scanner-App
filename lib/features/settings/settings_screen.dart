// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/app_config.dart';
import '../../services/fixture_loader.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _healthResult = '';
  bool _healthLoading = false;

  Future<void> _checkHealth() async {
    setState(() {
      _healthLoading = true;
      _healthResult = '';
    });
    try {
      final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
      final result = await client.getHealth();
      setState(() {
        _healthResult = result['data']?['ok'] == true ? 'OK' : 'Unhealthy';
      });
    } catch (e) {
      setState(() => _healthResult = 'Error: $e');
    } finally {
      setState(() => _healthLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'Settings',
      children: [
        SectionCard(
          title: 'Runtime mode',
          icon: LucideIcons.slidersHorizontal,
          children: [
            InfoTile(label: 'App version', value: AppConfig.appVersion),
            InfoTile(label: 'API baseline', value: AppConfig.apiBaseline),
            InfoTile(
              label: 'Fixture mode',
              value: AppConfig.fixtureMode ? 'enabled (default)' : 'off',
            ),
            InfoTile(
              label: 'Real API mode',
              value: AppConfig.fixtureMode
                  ? 'opt-in via dart-define'
                  : 'active (dev only)',
            ),
            InfoTile(label: 'Real API base URL', value: AppConfig.apiBaseUrl),
            InfoTile(label: 'API key support', value: 'server-side only later'),
          ],
        ),
        SectionCard(
          title: 'Health check',
          icon: LucideIcons.heartPulse,
          children: [
            Text(
              AppConfig.fixtureMode
                  ? 'Fixture mode — no API server needed.'
                  : 'Check that the local API is responding.',
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _healthLoading ? null : _checkHealth,
              icon: _healthLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.refreshCw),
              label: const Text('Check API health'),
            ),
            if (_healthResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _healthResult == 'OK'
                        ? LucideIcons.circleCheck
                        : LucideIcons.triangleAlert,
                    size: 18,
                    color: _healthResult == 'OK' ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_healthResult)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'No auth/token support. No provider calls. '
              'Read-only endpoints only.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!AppConfig.fixtureMode) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.info, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Android emulator: 127.0.0.1 is the emulator itself.'
                      ' Use the Zima LAN IP as API base URL.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        SectionCard(
          title: 'Roadmap',
          icon: LucideIcons.route,
          children: [
            InfoTile(label: 'Auth', value: 'planned v12.3'),
            InfoTile(label: 'Collection backend', value: 'planned v12.4'),
            InfoTile(label: 'Billing', value: 'planned v12.5'),
          ],
        ),
        SectionCard(
          title: 'Developer note',
          icon: LucideIcons.hardDrive,
          children: [
            Text(
              'Fixture mode keeps the app demoable without private APIs. Live mode is for local UAT against the SaveRoom backend.',
            ),
          ],
        ),
      ],
    );
  }
}
