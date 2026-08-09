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
        Text('SaveRoom', style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
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
    final colors = theme.colorScheme;
    return SizedBox(
      height: 500,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF122422).withValues(alpha: 0.78),
                    const Color(0xFF070909).withValues(alpha: 0.94),
                  ],
                ),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.52),
                    blurRadius: 46,
                    offset: const Offset(0, 30),
                  ),
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.11),
                    blurRadius: 70,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(top: 0, child: const _HeroCards()),
          Positioned(
            left: 24,
            right: 24,
            bottom: 116,
            child: Column(
              children: [
                Text(
                  'Collector workspace',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan, price and organise cards without turning the app into a data dump.',
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

class _HeroCards extends StatelessWidget {
  const _HeroCards();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: const [
        Positioned(
          top: 44,
          left: 44,
          child: _HeroCard(keyName: 'en:sv03-223', tilt: -0.16, scale: 0.84),
        ),
        Positioned(
          top: 34,
          right: 44,
          child: _HeroCard(keyName: 'en:sv02-201', tilt: 0.15, scale: 0.84),
        ),
        Positioned(
          top: 0,
          child: _HeroCard(keyName: 'en:sv04-234', tilt: 0, scale: 1),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.keyName,
    required this.tilt,
    required this.scale,
  });
  final String keyName;
  final double tilt;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final result = SearchResult.fromFixtureData(
      Fixtures.byKey(keyName)['data'] as Map<String, dynamic>? ?? const {},
    );
    return Transform.rotate(
      angle: tilt,
      child: Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.62),
                blurRadius: 34,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          child: CardThumbnail(
            imageUrls: result.imageUrlCandidates,
            cardName: result.name,
            width: 132,
            height: 184,
          ),
        ),
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
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [colors.primary, const Color(0xFF51D7B7)],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.30),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 20, 8),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.scanLine,
                color: Colors.black,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'SCAN A CARD',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(LucideIcons.arrowRight, color: Colors.black),
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
      radius: 28,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
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
        radius: 30,
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
        radius: 34,
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
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF071213), Color(0xFF020303)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -120,
            child: _Glow(size: 320, color: primary),
          ),
          const Positioned(
            bottom: 90,
            left: -120,
            child: _Glow(size: 260, color: saveRoomGold),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.20),
            color.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
