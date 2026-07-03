import 'package:flutter/material.dart';

import '../../services/fixture_loader.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: const FixtureLoader().loadCardDetail(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SaveRoomShell(
            title: 'Card detail',
            children: [Text('Fixture load failed: ${snapshot.error}')],
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
    final set = asMap(data['set']);
    final images = asMap(data['images']);
    final pricing = asMap(data['pricing']);
    final commercial = asMap(data['commercial']);
    final metadata = asMap(fixture['metadata']);
    final providers = asMap(data['provider_status']);
    final setText = joinPresent([
      textAt(set, 'name'),
      textAt(set, 'set_code'),
      textAt(card, 'collector_number'),
    ]);

    return [
      const FixtureBadge(),
      const SizedBox(height: 12),
      Text(
        textAt(card, 'name', 'Unknown card'),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 6),
      Text(setText, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      _ImagePanel(images: images),
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

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.images});

  final Map<String, dynamic> images;

  @override
  Widget build(BuildContext context) {
    final url = textAt(images, 'display_image_url');
    return SectionCard(
      title: 'Image',
      icon: Icons.image_outlined,
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image_not_supported_outlined, size: 44),
                const SizedBox(height: 8),
                Text(
                  url == '—'
                      ? 'No local image asset yet'
                      : 'Image URL/path shown below',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SelectableText(url),
      ],
    );
  }
}
