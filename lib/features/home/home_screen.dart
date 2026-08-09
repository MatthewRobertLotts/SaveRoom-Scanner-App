import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../widgets/card_thumbnail.dart';
import '../../widgets/glass_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.forceFixtureMode});

  // ponytail: kept for route compatibility; home is a static product shell.
  final bool? forceFixtureMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: saveRoomBackground,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
          children: const [
            _TopBar(),
            SizedBox(height: 18),
            _HeroCard(),
            SizedBox(height: 18),
            _ActionDock(),
            SizedBox(height: 24),
            _RecentlyViewedRail(),
          ],
        ),
      ),
      bottomNavigationBar: const _HomeBottomNav(),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'SaveRoom',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const _LiveApiPill(),
      ],
    );
  }
}

class _LiveApiPill extends StatelessWidget {
  const _LiveApiPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: saveRoomRaisedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '≋',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Live API',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(22, 46, 22, 22),
      child: Column(
        children: [
          Text(
            'Scan.Price.Collect.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 38),
          ),
          const SizedBox(height: 72),
          _ScanButton(
            onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: saveRoomPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '⌗',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Center(
                child: Text(
                  'SCAN A CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '→',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
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
            symbol: '⌕',
            label: 'Search',
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DockButton(
            symbol: '▥',
            label: 'Collection',
            onTap: () => Navigator.pushNamed(context, AppRoutes.collection),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DockButton(
            symbol: '☷',
            label: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ),
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.symbol,
    required this.label,
    required this.onTap,
  });
  final String symbol;
  final String label;
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
          children: [
            Text(
              symbol,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
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
  const _RecentlyViewedRail();

  static const _names = ['Arcanine', 'Charizard', 'Miraidon', 'Miraidon'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recently viewed', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _names.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _RecentMiniCard(name: _names[i]),
          ),
        ),
      ],
    );
  }
}

class _RecentMiniCard extends StatelessWidget {
  const _RecentMiniCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: GlassPanel(
        radius: 12,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CardThumbnail(
              imageUrls: const [],
              cardName: name,
              width: 74,
              height: 104,
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(symbol: '⌂', label: 'Home', selected: true),
            _NavItem(
              symbol: '⌕',
              label: 'Search',
              onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            ),
            _NavItem(
              symbol: '▢',
              label: 'Scan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
            ),
            _NavItem(
              symbol: '⚙',
              label: 'Settings',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.symbol,
    required this.label,
    this.selected = false,
    this.onTap,
  });
  final String symbol;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? saveRoomPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 74,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
