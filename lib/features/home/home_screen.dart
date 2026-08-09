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
        _HeroStage(fixtureMode: fixtureMode),
        const SizedBox(height: 18),
        _PrimaryActions(),
        const SizedBox(height: 18),
        const _CommandSearchBar(),
        const SizedBox(height: 24),
        ValueListenableBuilder<List<SearchResult>>(
          valueListenable: RecentlyViewed.instance,
          builder: (context, recent, _) => _RecentlyViewedRail(recent: recent),
        ),
      ],
    );
  }
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.fixtureMode});
  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accent: true,
      strong: true,
      radius: 38,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
              _RoundIcon(icon: LucideIcons.sparkles, color: saveRoomGold),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 186,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 12,
                  right: 104,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your card vault.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan, search, price and collect from one polished workspace.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 0,
                  child: _FloatingCard(keyName: 'en:sv04-234', tilt: 0.10),
                ),
                Positioned(
                  right: 56,
                  top: 42,
                  child: _FloatingCard(keyName: 'en:sv03-223', tilt: -0.09),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _HeroMetric(label: 'Cards', value: '0'),
              SizedBox(width: 10),
              _HeroMetric(label: 'Value', value: '£0'),
              SizedBox(width: 10),
              _HeroMetric(label: 'Listed', value: '0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({required this.keyName, required this.tilt});
  final String keyName;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final result = SearchResult.fromFixtureData(
      Fixtures.byKey(keyName)['data'] as Map<String, dynamic>? ?? const {},
    );
    return Transform.rotate(
      angle: tilt,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: CardThumbnail(
          imageUrls: result.imageUrlCandidates,
          cardName: result.name,
          width: 82,
          height: 116,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassPanel(
        strong: true,
        shadow: false,
        radius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GradientButton(
          label: 'SCAN A CARD',
          subtitle: 'Open camera frame',
          icon: LucideIcons.scanLine,
          onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SecondaryAction(
                label: 'Search',
                icon: LucideIcons.search,
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryAction(
                label: 'Collection',
                icon: LucideIcons.library,
                onTap: () => Navigator.pushNamed(context, AppRoutes.collection),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, const Color(0xFF52D7B8)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.28),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.black, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(LucideIcons.arrowRight, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
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
      radius: 26,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _RoundIcon(icon: icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _CommandSearchBar extends StatefulWidget {
  const _CommandSearchBar();

  @override
  State<_CommandSearchBar> createState() => _CommandSearchBarState();
}

class _CommandSearchBarState extends State<_CommandSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Search cards by name, set, or number…',
          prefixIcon: Icon(LucideIcons.search, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => Navigator.pushNamed(context, AppRoutes.search),
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
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) =>
                _RecentMiniCard(result: cards.elementAt(i)),
            separatorBuilder: (_, _) => const SizedBox(width: 14),
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
      width: 132,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CardThumbnail(
                imageUrls: result.imageUrlCandidates,
                cardName: result.name,
                width: 68,
                height: 96,
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
