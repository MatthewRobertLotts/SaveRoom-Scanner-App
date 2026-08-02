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
    final fixtureMode = forceFixtureMode ?? AppConfig.fixtureMode;
    return SaveRoomShell(
      title: 'SaveRoom',
      bottomBar: const _HomeBottomNav(),
      children: [
        _entrance(context, _OverviewCard(fixtureMode: fixtureMode)),
        const SizedBox(height: 12),
        _entrance(
          context,
          const _HomeSearchBar(),
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
                accent: Theme.of(context).colorScheme.primary,
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

// ponytail: no delay param on first child — first section appears immediately.
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

/// Compact collection overview — status + two metrics side by side.
/// Combines the old hero banner + separate metric tiles into one card.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.fixtureMode});

  final bool fixtureMode;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accent: true,
      strong: true,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            fixtureMode ? 'Fixture mode' : 'Live API ready',
            icon: fixtureMode ? LucideIcons.database : LucideIcons.circleCheck,
            dense: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _metric(context, LucideIcons.layers, 'Collection', '0'),
              const SizedBox(width: 24),
              _metric(context, LucideIcons.heart, 'Wishlist', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Primary search entry — navigates to full search on submit.
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
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      radius: 16,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search cards by name, set, or number…',
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}),
        onSubmitted: (query) {
          _controller.clear();
          Navigator.pushNamed(context, AppRoutes.search);
        },
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
