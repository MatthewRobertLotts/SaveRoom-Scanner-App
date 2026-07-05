import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../services/fixture_loader.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_image_panel.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

/// ponytail: cardKey passed via route args.
class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardKey =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'en:sv03-223';
    final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
    return FutureBuilder<Map<String, dynamic>>(
      future: client.getCardDetail(cardKey),
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

    final rarity = textAt(card, 'rarity');

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
            value: rarity == '—'
                ? (AppConfig.fixtureMode
                      ? 'Unknown / fixture pending'
                      : 'Unknown')
                : rarity,
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
          InfoTile(
            label: 'Providers',
            value: providers.keys
                .map(
                  (s) => s
                      .replaceAll('justtcg', 'JustTCG')
                      .replaceAll('cardmarket', 'Cardmarket')
                      .replaceAll('tcgplayer', 'TCGplayer')
                      .replaceAll('uk_ebay_sold', 'UK eBay sold')
                      .replaceAll('tcgdex', 'TCGdex'),
                )
                .join(', '),
          ),
        ],
      ),
    ];
  }

  // ponytail: _pricingRows replaces raw map textAt calls with formatted widgets.
  List<Widget> _pricingRows(Map<String, dynamic> pricing) {
    final evidence = asMap(pricing['evidence_summary']);
    final pp = asMap(pricing['primary_price']);
    final fp = asMap(pricing['fallback_price']);
    return [
      _PriceRow(
        label: 'Primary price',
        price: pp,
        icon: Icons.trending_up_outlined,
      ),
      _PriceRow(
        label: 'Fallback price',
        price: fp,
        icon: Icons.trending_down_outlined,
      ),
      SectionCard(
        title: 'Evidence',
        icon: Icons.fact_check_outlined,
        children: [
          InfoTile(
            label: 'Total',
            value: _orDash(evidence['total_evidence']),
            icon: Icons.numbers_outlined,
          ),
          InfoTile(
            label: 'UK evidence',
            value: _orDash(evidence['uk_evidence']),
            icon: Icons.language_outlined,
          ),
          InfoTile(
            label: 'Source',
            value: _humanSource(textAt(evidence, 'source')),
            icon: Icons.source_outlined,
          ),
        ],
      ),
    ];
  }

  static String _orDash(Object? value) {
    if (value == null) return '—';
    final s = value.toString().trim();
    return s.isEmpty ? '—' : s;
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

// ── Top-level helpers (available to both CardDetailScreen and _PriceRow) ──

String _humanSource(String raw) {
  if (raw == '—' || raw.isEmpty) return raw;
  return raw
      .replaceAll(
        'rapidapi_ebay_average_selling_price',
        'RapidAPI eBay average selling price',
      )
      .replaceAll('rapidapi', 'RapidAPI')
      .replaceAll('justtcg', 'JustTCG')
      .replaceAll('cardmarket', 'Cardmarket')
      .replaceAll('tcgplayer', 'TCGplayer')
      .replaceAll('uk_ebay_sold', 'UK eBay sold')
      .replaceAll('tcgdex', 'TCGdex')
      .split('_')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
      .join(' ');
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.price, this.icon});

  final String label;
  final Map<String, dynamic> price;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (price.isEmpty) {
      return SectionCard(
        title: label,
        icon: icon ?? Icons.attach_money_outlined,
        children: const [Text('—')],
      );
    }
    final amount = price['amount'];
    final currency = textAt(price, 'currency', 'GBP');
    final source = _humanSource(textAt(price, 'source'));
    final formattedAmount = amount is num
        ? '${currency == 'GBP' ? '£' : ''}${amount.toStringAsFixed(2)} $currency'
        : '$amount $currency';
    return SectionCard(
      title: label,
      icon: icon ?? Icons.attach_money_outlined,
      children: [
        Text(
          formattedAmount,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (source != '—' && source.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                const Icon(Icons.source_outlined, size: 14),
                const SizedBox(width: 4),
                Expanded(child: Text(source)),
              ],
            ),
          ),
      ],
    );
  }
}
