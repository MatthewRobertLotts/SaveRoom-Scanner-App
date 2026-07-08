import 'package:flutter/material.dart';

import '../../services/recent_cards.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_thumbnail.dart';
import '../../config/app_config.dart';
import '../../app/app_routes.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/primary_action_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/saveroom_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recent = RecentlyViewed.recent;
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
          title: 'Search cards',
          subtitle: 'Find cards by name, set, or partial name',
          icon: Icons.search,
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const SizedBox(height: 8),
        PrimaryActionCard(
          title: 'Camera scanner',
          subtitle: 'Coming soon -- search foundation is ready',
          icon: Icons.document_scanner_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const SizedBox(height: 24),
        SectionCard(
          title: 'Recently viewed',
          icon: Icons.history,
          children: [
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Cards you open will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              _RecentList(),
          ],
        ),
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
        // Settings always visible, dev/testing actions in fixture mode only
        if (AppConfig.fixtureMode) ...[
          const SizedBox(height: 8),
          _SmallAction(
            'View Mock Card',
            Icons.style_outlined,
            AppRoutes.cardDetail,
          ),
        ],
        const SizedBox(height: 8),
        _SmallAction('Settings', Icons.tune_outlined, AppRoutes.settings),
      ],
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList();

  @override
  Widget build(BuildContext context) {
    final recent = RecentlyViewed.recent;
    if (recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Cards you open will appear here',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = recent[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CardThumbnail(
            imageUrls: r.imageUrlCandidates,
            cardName: r.name,
          ),
          title: Text(
            r.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            r.displayText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.cardDetail,
            arguments: CardDetailArgs(cardKey: r.cardKey, fallback: r),
          ),
        );
      },
    );
  }
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
