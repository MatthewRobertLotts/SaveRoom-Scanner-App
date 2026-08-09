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
import '../../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.forceFixtureMode});

  final bool? forceFixtureMode;

  @override
  Widget build(BuildContext context) {
    final fixtureMode = forceFixtureMode ?? AppConfig.fixtureMode;
    return Scaffold(
      backgroundColor: saveRoomBackground,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _HomeBackdrop()),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
              children: [
                _TopBar(fixtureMode: fixtureMode),
                const SizedBox(height: 18),
                const _ObjectHero(),
                const SizedBox(height: 18),
                const _ActionDock(),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<SearchResult>>(
                  valueListenable: RecentlyViewed.instance,
                  builder: (context, recent, _) =>
                      _RecentlyViewedRail(recent: recent),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _HomeBottomNav(),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.fixtureMode});
  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'SaveRoom',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(width: 12),
        StatusPill(
          fixtureMode ? 'Fixture mode' : 'Live API',
          icon: fixtureMode ? LucideIcons.database : LucideIcons.wifi,
          dense: true,
        ),
      ],
    );
  }
}

class _ObjectHero extends StatelessWidget {
  const _ObjectHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 390,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: saveRoomSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 58,
            child: Column(
              children: [
                Text(
                  'Scan. Price. Vault.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 8),
                Text(
                  'A premium utility for checking card value, evidence and collection state fast.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: _ScanButton(
              onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colors.primary,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.30),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.scanLine,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Center(
                child: Text(
                  'SCAN A CARD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const Icon(LucideIcons.arrowRight, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DockButton(
            label: 'Search',
            icon: LucideIcons.search,
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DockButton(
            label: 'Vault',
            icon: LucideIcons.library,
            onTap: () => Navigator.pushNamed(context, AppRoutes.collection),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DockButton(
            label: 'Settings',
            icon: LucideIcons.slidersHorizontal,
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ),
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      radius: 8,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
          height: 202,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) =>
                _RecentMiniCard(result: cards.elementAt(i)),
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
      width: 142,
      child: GlassPanel(
        radius: 12,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CardThumbnail(
                imageUrls: result.imageUrlCandidates,
                cardName: result.name,
                width: 74,
                height: 104,
              ),
            ),
            const Spacer(),
            Text(
              result.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
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
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: GlassPanel(
        strong: true,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: NavigationBar(
          selectedIndex: 0,
          height: 64,
          elevation: 0,
          backgroundColor: Colors.transparent,
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
            NavigationDestination(
              icon: Icon(LucideIcons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.scanLine),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: saveRoomBackground);
}
