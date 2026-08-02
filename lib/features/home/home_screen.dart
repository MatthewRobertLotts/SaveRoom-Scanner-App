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
        Text(
          'Honest collecting. Clear card data.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
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
        _ScanHeroCard(
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const SizedBox(height: 14),
        _SearchLaunchCard(
          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        const SizedBox(height: 28),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => _RecentlyViewedRail(recent: recent),
        ),
        const SizedBox(height: 26),
        const Text('Your space', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _SpaceTile(title: 'COLLECTION', value: '0 cards'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SpaceTile(title: 'WISHLIST', value: '0 cards'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanHeroCard extends StatelessWidget {
  const _ScanHeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.primary.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.primary.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCAN A CARD',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF5AC8FF),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Identify in seconds',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Camera recognition with review before save',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bolt, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchLaunchCard extends StatelessWidget {
  const _SearchLaunchCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.search, size: 18),
        title: const Text('Search cards'),
        subtitle: const Text('Search by name, set, number or key'),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 28),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
