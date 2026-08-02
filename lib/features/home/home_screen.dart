import 'package:flutter/material.dart';

import '../../services/recent_cards.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_thumbnail.dart';
import '../../config/app_config.dart';
import '../../app/app_routes.dart';
import '../../widgets/primary_action_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/saveroom_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.forceFixtureMode});

  final bool? forceFixtureMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fixtureMode = forceFixtureMode ?? AppConfig.fixtureMode;
    return SaveRoomShell(
      title: 'SaveRoom Scanner',
      children: [
        Text(
          'SaveRoom Scanner',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Search and identify Pokémon cards',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusPill(
              fixtureMode ? 'Fixture mode' : 'Live API ready',
              icon: fixtureMode
                  ? Icons.developer_mode
                  : Icons.check_circle_outline,
              dense: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryActionCard(
          title: 'Search cards',
          subtitle: 'Find cards by name, set, or partial name',
          icon: Icons.search,
          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        const SizedBox(height: 8),
        PrimaryActionCard(
          title: 'Camera scanner',
          subtitle: 'Coming soon',
          icon: Icons.document_scanner_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const SizedBox(height: 32),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => SectionCard(
            title: 'Recently viewed',
            icon: Icons.history,
            dense: true,
            children: [
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Cards you open will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.separated(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.cardDetail,
                        arguments: CardDetailArgs(
                          cardKey: r.cardKey,
                          fallback: r,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Dev/testing actions in fixture mode only
        if (fixtureMode) ...[
          const SectionCard(
            title: 'Testing',
            icon: Icons.developer_mode,
            dense: true,
            children: [
              _SmallAction(
                'View Mock Card',
                Icons.style_outlined,
                AppRoutes.cardDetail,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const _SmallAction('Settings', Icons.tune_outlined, AppRoutes.settings),
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
    elevation: 0,
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    ),
  );
}
