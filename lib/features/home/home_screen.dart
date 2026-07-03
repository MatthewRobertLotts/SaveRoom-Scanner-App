import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/primary_action_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';
import '../../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'SaveRoom Scanner',
      children: [
        Text(
          'SaveRoom Scanner',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Your card intelligence platform',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusPill('API baseline: v12.2.0', icon: Icons.hub_outlined),
            FixtureBadge(),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryActionCard(
          title: 'Start Scanner',
          subtitle: 'Use the fixture scan flow for now',
          icon: Icons.document_scanner_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const Row(
          children: [
            Expanded(
              child: _SmallAction(
                'View Mock Card',
                Icons.style_outlined,
                AppRoutes.cardDetail,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SmallAction(
                'Collection',
                Icons.collections_bookmark_outlined,
                AppRoutes.collection,
              ),
            ),
          ],
        ),
        const _SmallAction('Settings', Icons.tune_outlined, AppRoutes.settings),
        const SectionCard(
          title: 'Roadmap status',
          icon: Icons.route_outlined,
          children: [
            _StatusLine('Fixture data ready'),
            _StatusLine('Real API mode available via dart-define'),
            _StatusLine('Auth planned v12.3'),
            _StatusLine('Collection backend planned v12.4'),
          ],
        ),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    ),
  );
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
