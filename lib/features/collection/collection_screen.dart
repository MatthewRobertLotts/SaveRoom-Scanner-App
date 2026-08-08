import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/saveroom_shell.dart';
import '../../widgets/status_pill.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'Collection',
      children: [
        const StatusPill(
          'Collection tools coming next',
          icon: LucideIcons.layers,
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.16,
          children: const [
            _MetricCard(label: 'Cards', value: '0', icon: LucideIcons.layers),
            _MetricCard(label: 'Wishlist', value: '0', icon: LucideIcons.heart),
            _MetricCard(
              label: 'Est. value',
              value: '£0',
              icon: LucideIcons.badgePoundSterling,
            ),
            _MetricCard(label: 'Listed', value: '0', icon: LucideIcons.store),
          ],
        ),
        const SizedBox(height: 16),
        GlassPanel(
          accent: true,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Start with search',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Cards you add will appear here. No fake inventory is shown before the backend collection flow exists.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                icon: const Icon(LucideIcons.search),
                label: const Text('Search cards'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      strong: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: saveRoomGold, size: 22),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
