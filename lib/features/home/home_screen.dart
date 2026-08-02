import 'package:flutter/material.dart';

import '../../services/recent_cards.dart';
import '../../services/saveroom_api_client.dart';
import '../../services/fixtures.dart';
import '../../widgets/card_thumbnail.dart';
import '../../config/app_config.dart';
import '../../app/app_routes.dart';
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
      title: 'SaveRoom',
      bottomBar: const _HomeBottomNav(),
      children: [
        _DashboardHero(fixtureMode: fixtureMode),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.style_outlined,
                title: 'Collection',
                value: '0',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                value: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.04,
          children: [
            _DashboardActionTile(
              label: 'SCAN A CARD',
              title: 'Camera scanner',
              icon: Icons.document_scanner_outlined,
              accent: colors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
            ),
            _DashboardActionTile(
              label: 'SEARCH',
              title: 'Search cards',
              icon: Icons.search,
              accent: const Color(0xFF58E69B),
              onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            ),
            const _DashboardActionTile(
              label: 'COLLECTION',
              title: 'Browse cards',
              icon: Icons.inventory_2_outlined,
              accent: Color(0xFFA78BFA),
            ),
            const _DashboardActionTile(
              label: 'WISHLIST',
              title: 'Saved targets',
              icon: Icons.bookmark_border,
              accent: Color(0xFFFFB020),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => _RecentlyViewedRail(recent: recent),
        ),
      ],
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.fixtureMode});

  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.22),
            colors.surfaceContainerHighest,
          ],
        ),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            fixtureMode ? 'Fixture mode' : 'Live API ready',
            icon: fixtureMode
                ? Icons.developer_mode
                : Icons.check_circle_outline,
            dense: true,
          ),
          const SizedBox(height: 22),
          Text(
            'Your collector dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Scan, search and review Pokémon cards without the clutter.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({
    required this.label,
    required this.title,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyViewedRail extends StatelessWidget {
  const _RecentlyViewedRail({required this.recent});

  final List<SearchResult> recent;

  @override
  Widget build(BuildContext context) {
    final cards = recent.isEmpty
        ? Fixtures.cardKeys
              .take(3)
              .map(
                (key) => SearchResult.fromFixtureData(
                  Fixtures.byKey(key)['data'] as Map<String, dynamic>? ??
                      const {},
                ),
              )
        : recent.take(3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently viewed',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        if (recent.isEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Cards you open will appear here',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: cards
              .map(
                (r) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _RecentMiniCard(result: r),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RecentMiniCard extends StatelessWidget {
  const _RecentMiniCard({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CardThumbnail(
                imageUrls: result.imageUrlCandidates,
                cardName: result.name,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              result.displayText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavLabel('Home', selected: true),
            _NavLabel('Search'),
            _NavLabel('Scan'),
            _NavLabel('Collection'),
          ],
        ),
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.text, {this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: selected ? Theme.of(context).colorScheme.primary : null,
      fontWeight: FontWeight.w800,
    ),
  );
}
