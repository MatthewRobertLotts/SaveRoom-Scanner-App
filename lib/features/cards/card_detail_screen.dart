import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../services/fixture_loader.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_image_panel.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
    return FutureBuilder<Map<String, dynamic>>(
      future: client.getCardDetail('en:sv03-223'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SaveRoomShell(
            title: 'Card detail',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      '${AppConfig.fixtureMode ? 'Fixture' : 'API'} load failed',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}'),
                    if (!AppConfig.fixtureMode) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Start local API at ${AppConfig.apiBaseUrl} '
                        'or switch back to fixture mode.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const SaveRoomShell(
            title: 'Card detail',
            children: [LinearProgressIndicator()],
          );
        }
        return SaveRoomShell(
          title: 'Card detail',
          children: _content(context, snapshot.data!),
        );
      },
    );
  }

  List<Widget> _content(BuildContext context, Map<String, dynamic> fixture) {
    final data = asMap(fixture['data']);
    final card = asMap(data['card']);
    final pricing = asMap(data['pricing']);
    final commercial = asMap(data['commercial']);
    final metadata = asMap(fixture['metadata']);
    final providers = asMap(data['provider_status']);

    return [
      if (AppConfig.fixtureMode) const FixtureBadge(),
      if (!AppConfig.fixtureMode)
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Chip(
            avatar: Icon(Icons.cloud_done_outlined, size: 18),
            label: Text('Live API mode'),
          ),
        ),
      const SizedBox(height: 12),
      CardImagePanel.fromData(data),
      const SizedBox(height: 8),
      SectionCard(
        title: 'Card facts',
        icon: Icons.style_outlined,
        children: [
          InfoTile(
            label: 'Language',
            value: textAt(card, 'language_code'),
            icon: Icons.language_outlined,
          ),
          InfoTile(
            label: 'Rarity',
            value: textAt(card, 'rarity'),
            icon: Icons.star_outline,
          ),
          InfoTile(
            label: 'Card key',
            value: textAt(card, 'card_key'),
            icon: Icons.key_outlined,
          ),
        ],
      ),
      SectionCard(
        title: 'Pricing / evidence',
        icon: Icons.query_stats_outlined,
        children: _pricingRows(pricing),
      ),
      SectionCard(
        title: 'Inventory / commercial',
        icon: Icons.sell_outlined,
        children: _commercialRows(commercial),
      ),
      SectionCard(
        title: 'Source / provenance',
        icon: Icons.verified_outlined,
        children: [
          InfoTile(label: 'Contract', value: textAt(metadata, 'contract')),
          InfoTile(
            label: 'API version',
            value: textAt(metadata, 'api_version'),
          ),
          InfoTile(label: 'Sanitized', value: textAt(metadata, 'sanitized')),
          InfoTile(label: 'Providers', value: providers.keys.join(', ')),
        ],
      ),
      SectionCard(
        title: 'Raw fixture debug',
        icon: Icons.data_object_outlined,
        children: [
          Text(
            fixture.toString(),
            maxLines: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ];
  }

  List<Widget> _pricingRows(Map<String, dynamic> pricing) {
    final evidence = asMap(pricing['evidence_summary']);
    return [
      InfoTile(label: 'Primary price', value: textAt(pricing, 'primary_price')),
      InfoTile(
        label: 'Fallback price',
        value: textAt(pricing, 'fallback_price'),
      ),
      InfoTile(label: 'Evidence source', value: textAt(evidence, 'source')),
      InfoTile(
        label: 'Evidence count',
        value: textAt(evidence, 'evidence_count'),
      ),
    ];
  }

  List<Widget> _commercialRows(Map<String, dynamic> commercial) {
    final skus = asList(commercial['sellable_skus']);
    final firstSku = skus.isNotEmpty
        ? asMap(skus.first)
        : const <String, dynamic>{};
    return [
      InfoTile(
        label: 'Default SKU',
        value: textAt(commercial, 'default_sku_id'),
      ),
      InfoTile(label: 'Sellable SKUs', value: '${skus.length}'),
      InfoTile(
        label: 'First condition',
        value: textAt(firstSku, 'condition_code'),
      ),
      InfoTile(label: 'SKU status', value: textAt(firstSku, 'status')),
    ];
  }
}
