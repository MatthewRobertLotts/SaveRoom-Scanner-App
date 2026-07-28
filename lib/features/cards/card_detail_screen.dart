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
  const CardDetailScreen({
    super.key,
    SaveRoomApiClient? client,
    this.forceFixtureMode,
  }) : _client = client;

  final SaveRoomApiClient? _client;
  final bool? forceFixtureMode;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final cardKey = switch (args) {
      CardDetailArgs(:final cardKey) => cardKey,
      String value => value,
      _ => 'en:sv03-223',
    };
    final fallback = args is CardDetailArgs ? args.fallback : null;
    final client =
        _client ??
        SaveRoomApiClient(
          fixtureLoader: const FixtureLoader(),
          forceFixtureMode: forceFixtureMode,
        );
    return FutureBuilder<Map<String, dynamic>>(
      future: client.getCardDetail(cardKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (fallback != null && fallback.hasFallbackDetail) {
            return SaveRoomShell(
              title: 'Card detail',
              children: _content(
                context,
                fallback.toFallbackDetailResponse(),
                isFallbackPreview: true,
              ),
            );
          }
          return _unavailable(context, cardKey);
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

  Widget _unavailable(BuildContext context, String cardKey) {
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
                'Card detail unavailable',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The API could not load this card right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Card key: $cardKey',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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

  List<Widget> _content(
    BuildContext context,
    Map<String, dynamic> fixture, {
    bool isFallbackPreview = false,
  }) {
    final data = asMap(fixture['data']);
    final card = asMap(data['card']);
    final pricing = asMap(data['pricing']);
    final providers = asMap(data['provider_status']);

    final set = asMap(data['set']);
    final name = textAt(card, 'name', 'Unknown card');
    final setName = textAt(set, 'name', textAt(set, 'localized_name'));
    final number = textAt(card, 'collector_number', textAt(card, 'number'));
    final language = _humanLanguage(textAt(card, 'language_code'));
    final rarity = textAt(card, 'rarity');

    return [
      if (AppConfig.fixtureMode) const FixtureBadge(),
      if (isFallbackPreview)
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Chip(
            avatar: Icon(Icons.info_outline, size: 18),
            label: Text('Preview from search result'),
          ),
        ),
      const SizedBox(height: 12),
      _summaryRow(
        context,
        data: data,
        name: name,
        setName: setName,
        number: number,
        language: language,
        rarity: rarity,
        pricing: pricing,
        isFallbackPreview: isFallbackPreview,
      ),
      const SizedBox(height: 12),
      const _HeroActions(),
      const SizedBox(height: 12),
      SectionCard(
        title: 'Pricing / evidence',
        icon: Icons.query_stats_outlined,
        children: _pricingRows(context, pricing, providers),
      ),
      if (isFallbackPreview)
        const SectionCard(
          title: 'Detail status',
          icon: Icons.info_outline,
          children: [
            Text(
              'Full card detail is temporarily unavailable. Showing the tapped search result instead.',
            ),
          ],
        ),
    ];
  }

  Widget _summaryRow(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String name,
    required String setName,
    required String number,
    required String language,
    required String rarity,
    required Map<String, dynamic> pricing,
    required bool isFallbackPreview,
  }) {
    final displayRarity = rarity == '—'
        ? (AppConfig.fixtureMode ? 'Unknown / fixture pending' : 'Unknown')
        : rarity;
    return LayoutBuilder(
      builder: (context, constraints) {
        // ponytail: one proportion bump; responsive later if tablets matter.
        final imageHeight = constraints.maxWidth >= 360 ? 320.0 : 290.0;
        final imageWidth = imageHeight * 5 / 7;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageWidth,
              child: CardImagePanel.fromData(
                data,
                imageHeight: imageHeight,
                showTitle: false,
                showMetadata: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GlanceLine(label: 'Set', value: setName),
                  _GlanceLine(label: 'No.', value: number),
                  _GlanceLine(label: 'Lang', value: language),
                  _GlanceLine(label: 'Rarity', value: displayRarity),
                  _GlanceLine(label: 'Price', value: _priceGlance(pricing)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ponytail: one readable summary beats backend primary/fallback/debug sections.
  List<Widget> _pricingRows(
    BuildContext context,
    Map<String, dynamic> pricing,
    Map<String, dynamic> providers,
  ) {
    final evidence = asMap(pricing['evidence_summary']);
    final pp = asMap(pricing['primary_price']);
    final fp = asMap(pricing['fallback_price']);
    final hasPrimaryPrice = _hasAmount(pp);
    final hasFallbackPrice = _hasAmount(fp);
    final rows = <Widget>[];
    if (hasPrimaryPrice) {
      rows.add(
        _PriceRow(
          label: 'Market price',
          price: pp,
          icon: Icons.trending_up_outlined,
        ),
      );
    } else if (hasFallbackPrice) {
      rows.add(
        _PriceRow(
          label: 'Estimated price',
          price: fp,
          icon: Icons.trending_up_outlined,
        ),
      );
    }
    final source = _pricingSource(
      pricing,
      evidence,
      hasPrimaryPrice
          ? pp
          : (hasFallbackPrice ? fp : const <String, dynamic>{}),
    );
    final hasEvidence =
        _hasPositiveCount(evidence['total_evidence']) ||
        _hasPositiveCount(evidence['uk_evidence']);
    if (evidence.isNotEmpty && hasEvidence) {
      rows.addAll([
        Text('Evidence', style: Theme.of(context).textTheme.titleSmall),
        InfoTile(
          label: 'Total',
          value: _evidenceCount(evidence['total_evidence']),
          icon: Icons.fact_check_outlined,
        ),
        InfoTile(
          label: 'UK evidence',
          value: _evidenceCount(evidence['uk_evidence'], zeroText: 'None yet'),
          icon: Icons.language_outlined,
        ),
        if (source != '—')
          InfoTile(label: 'Source', value: source, icon: Icons.source_outlined),
      ]);
    }
    if (providers.isNotEmpty &&
        (hasPrimaryPrice || hasFallbackPrice || hasEvidence)) {
      rows.add(
        InfoTile(
          label: 'Data sources',
          value: providers.keys
              .map((s) => _humanSource(s.toString()))
              .join(', '),
          icon: Icons.verified_outlined,
        ),
      );
    }
    if (rows.isEmpty ||
        (!hasEvidence && !hasPrimaryPrice && !hasFallbackPrice)) {
      rows.clear();
      rows.add(
        const Text('No pricing or evidence is available for this card yet.'),
      );
    }
    return rows;
  }

  static String _orDash(Object? value) {
    if (value == null) return '—';
    final s = value.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  static String _evidenceCount(Object? value, {String zeroText = 'None'}) {
    final text = _orDash(value);
    if (text == '—') return 'No evidence available yet';
    if (text == '0') return zeroText;
    return '$text market observations';
  }

  static bool _hasPositiveCount(Object? value) {
    final n = num.tryParse(value?.toString() ?? '');
    return n != null && n > 0;
  }

  static bool _hasAmount(Map<String, dynamic> price) {
    final amount = price['amount'];
    if (amount is num) return amount > 0;
    final n = num.tryParse(amount?.toString() ?? '');
    return n != null && n > 0;
  }

  static String _pricingSource(
    Map<String, dynamic> pricing,
    Map<String, dynamic> evidence,
    Map<String, dynamic> price,
  ) {
    final breakdown = asList(pricing['source_breakdown']);
    final firstBreakdown = breakdown.isNotEmpty
        ? asMap(breakdown.first)
        : const <String, dynamic>{};
    return _humanSource(
      textAt(
        evidence,
        'source',
        textAt(price, 'source', textAt(firstBreakdown, 'source')),
      ),
    );
  }

  static String _priceGlance(Map<String, dynamic> pricing) {
    final pp = asMap(pricing['primary_price']);
    final fp = asMap(pricing['fallback_price']);
    final price = _hasAmount(pp) ? pp : (_hasAmount(fp) ? fp : null);
    if (price == null) return 'No pricing yet';
    final amount = price['amount'];
    final currency = textAt(price, 'currency', 'GBP');
    return amount is num
        ? '${currency == 'GBP' ? '£' : ''}${amount.toStringAsFixed(2)}'
        : amount.toString();
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonal(onPressed: null, child: Text('Add to inventory')),
        FilledButton.tonal(onPressed: null, child: Text('Add to wishlist')),
        FilledButton.tonal(onPressed: null, child: Text('Compare prices')),
      ],
    );
  }
}

class _GlanceLine extends StatelessWidget {
  const _GlanceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
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

String _humanLanguage(String raw) => switch (raw.toLowerCase()) {
  'en' => 'English',
  'ja' => 'Japanese',
  'fr' => 'French',
  'de' => 'German',
  'es' => 'Spanish',
  'it' => 'Italian',
  'pt' => 'Portuguese',
  'ko' => 'Korean',
  'zh' => 'Chinese',
  _ => raw,
};

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.price, this.icon});

  final String label;
  final Map<String, dynamic> price;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final amount = price['amount'];
    final currency = textAt(price, 'currency', 'GBP');
    final source = _humanSource(textAt(price, 'source'));
    if (amount == null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon ?? Icons.attach_money_outlined),
        title: Text(label, style: Theme.of(context).textTheme.labelLarge),
        subtitle: Text(source == '—' ? 'Price evidence available' : source),
      );
    }
    final formattedAmount = amount is num
        ? '${currency == 'GBP' ? '£' : ''}${amount.toStringAsFixed(2)} $currency'
        : '$amount $currency';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon ?? Icons.attach_money_outlined),
      title: Text(label, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(source == '—' ? 'Pricing evidence available' : source),
      trailing: Text(
        formattedAmount,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
