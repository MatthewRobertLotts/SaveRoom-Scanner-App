import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../config/app_config.dart';
import '../../services/fixtures.dart';
import '../../services/recent_cards.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_thumbnail.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/saveroom_shell.dart';
import '../../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.forceFixtureMode});

  final bool? forceFixtureMode;

  @override
  Widget build(BuildContext context) {
    final fixtureMode = forceFixtureMode ?? AppConfig.fixtureMode;
    return SaveRoomShell(
      title: 'SaveRoom',
      bottomBar: const _HomeBottomNav(),
      children: [
        _HeroDashboard(fixtureMode: fixtureMode),
        const SizedBox(height: 18),
        const _HomeSearchBar(),
        const SizedBox(height: 18),
        _ActionStrip(
          actions: [
            _HomeAction(
              'SCAN A CARD',
              'Camera frame',
              LucideIcons.scanLine,
              () => Navigator.pushNamed(context, AppRoutes.scanner),
            ),
            _HomeAction(
              'Search',
              'Find cards',
              LucideIcons.search,
              () => Navigator.pushNamed(context, AppRoutes.search),
            ),
            _HomeAction(
              'Collection',
              'Your vault',
              LucideIcons.library,
              () => Navigator.pushNamed(context, AppRoutes.collection),
            ),
          ],
        ),
        const SizedBox(height: 26),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => _RecentlyViewedRail(recent: recent),
        ),
      ],
    );
  }
}

class _HeroDashboard extends StatelessWidget {
  const _HeroDashboard({required this.fixtureMode});

  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accent: true,
      strong: true,
      radius: 34,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                fixtureMode ? 'Fixture mode' : 'Live API',
                icon: fixtureMode ? LucideIcons.database : LucideIcons.wifi,
                dense: true,
              ),
              const Spacer(),
              Icon(LucideIcons.sparkles, color: saveRoomGold),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: _HeroCopy()),
              const SizedBox(width: 12),
              _CardStackPreview(),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _MetricPill('Cards', '0'),
              SizedBox(width: 8),
              _MetricPill('Value', '£0'),
              SizedBox(width: 8),
              _MetricPill('List', '0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card scanner', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Look up cards, check market price, and build the collection flow without fake inventory.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CardStackPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 92,
      height: 128,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 8,
            child: _MiniCard(color: colors.secondary.withValues(alpha: 0.42)),
          ),
          Positioned(
            left: 4,
            top: 0,
            child: _MiniCard(color: colors.primary.withValues(alpha: 0.42)),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 96,
      decoration: BoxDecoration(
        color: saveRoomMutedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 5, width: 42, color: Colors.white24),
          const SizedBox(height: 4),
          Container(height: 4, width: 30, color: Colors.white12),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: saveRoomBackground.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar();

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Search cards by name, set, or number…',
        prefixIcon: Icon(LucideIcons.search, size: 20),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => Navigator.pushNamed(context, AppRoutes.search),
    );
  }
}

class _HomeAction {
  const _HomeAction(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({required this.actions});
  final List<_HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _ActionCard(action: actions[i]),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemCount: actions.length,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: GlassPanel(
        onTap: action.onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(action.icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(action.title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              action.subtitle,
              style: Theme.of(context).textTheme.labelSmall,
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
        Text('Recently viewed', style: Theme.of(context).textTheme.titleLarge),
        if (recent.isEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Cards you open will appear here',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) =>
                _RecentMiniCard(result: cards.elementAt(i)),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: cards.length,
          ),
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
    return SizedBox(
      width: 126,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CardThumbnail(
                imageUrls: result.imageUrlCandidates,
                cardName: result.name,
              ),
            ),
            const Spacer(),
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
    return NavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedIndex: 0,
      height: 64,
      onDestinationSelected: (index) {
        final route = switch (index) {
          1 => AppRoutes.search,
          2 => AppRoutes.scanner,
          3 => AppRoutes.settings,
          _ => null,
        };
        if (route != null) Navigator.pushNamed(context, route);
      },
      destinations: const [
        NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
        NavigationDestination(icon: Icon(LucideIcons.search), label: 'Search'),
        NavigationDestination(icon: Icon(LucideIcons.scanLine), label: 'Scan'),
        NavigationDestination(
          icon: Icon(LucideIcons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
