import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_routes.dart';
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
    final colors = Theme.of(context).colorScheme;
    final fixtureMode = forceFixtureMode ?? AppConfig.fixtureMode;
    return SaveRoomShell(
      title: 'SaveRoom',
      bottomBar: const _HomeBottomNav(),
      children: [
        _entrance(context, _DashboardHero(fixtureMode: fixtureMode)),
        const SizedBox(height: 14),
        _entrance(
          context,
          const Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: LucideIcons.layers,
                  title: 'Collection',
                  value: '0',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: LucideIcons.heart,
                  title: 'Wishlist',
                  value: '0',
                ),
              ),
            ],
          ),
          delay: const Duration(milliseconds: 60),
        ),
        const SizedBox(height: 16),
        _entrance(
          context,
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
                icon: LucideIcons.scanLine,
                accent: colors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
              ),
              _DashboardActionTile(
                label: 'SEARCH',
                title: 'Search cards',
                icon: LucideIcons.search,
                accent: const Color(0xFFFF9A57),
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              const _DashboardActionTile(
                label: 'COLLECTION',
                title: 'Browse cards',
                icon: LucideIcons.library,
                accent: Color(0xFFC7C7CC),
              ),
              const _DashboardActionTile(
                label: 'WISHLIST',
                title: 'Saved targets',
                icon: LucideIcons.bookmark,
                accent: Color(0xFFFFB269),
              ),
            ],
          ),
          delay: const Duration(milliseconds: 120),
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => _entrance(
            context,
            _RecentlyViewedRail(recent: recent),
            delay: const Duration(milliseconds: 180),
          ),
        ),
      ],
    );
  }
}

Widget _entrance(
  BuildContext context,
  Widget child, {
  Duration delay = Duration.zero,
}) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  final total = Duration(milliseconds: 260 + delay.inMilliseconds);
  final wait = delay.inMilliseconds / total.inMilliseconds;
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: total,
    curve: Curves.easeOut,
    builder: (context, value, animatedChild) {
      final progress = ((value - wait) / (1 - wait)).clamp(0.0, 1.0);
      return Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - progress)),
          child: animatedChild,
        ),
      );
    },
    child: child,
  );
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.fixtureMode});

  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GlassPanel(
      accent: true,
      strong: true,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -28,
            child: Icon(
              LucideIcons.sparkles,
              size: 118,
              color: colors.primary.withValues(alpha: 0.055),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                fixtureMode ? 'Fixture mode' : 'Live API ready',
                icon: fixtureMode
                    ? LucideIcons.database
                    : LucideIcons.circleCheck,
                dense: true,
              ),
              const SizedBox(height: 22),
              Text(
                'Your collector dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Scan, search and review Pokémon cards without the clutter.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
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
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: GlassPanel(
        onTap: onTap,
        accent: enabled,
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.24)),
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
    return GlassPanel(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
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
                (result) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _RecentMiniCard(result: result),
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
    return GlassPanel(
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
