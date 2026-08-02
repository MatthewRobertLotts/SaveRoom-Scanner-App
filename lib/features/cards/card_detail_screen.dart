import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_config.dart';
import '../../services/fixture_loader.dart';
import '../../services/saveroom_api_client.dart';
import '../../widgets/card_image_panel.dart';
import '../../widgets/fixture_badge.dart';
import '../../widgets/glass_panel.dart';
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
              bottomBar: const _CollectorActionBar(),
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
          return const _DetailLoading();
        }
        return SaveRoomShell(
          title: 'Card detail',
          bottomBar: const _CollectorActionBar(),
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
              const Icon(LucideIcons.circleAlert, size: 48),
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
            avatar: Icon(LucideIcons.info, size: 18),
            label: Text('Preview from search result'),
          ),
        ),
      const SizedBox(height: 12),
      _IdentityHeader(name: name, setName: setName, number: number),
      const SizedBox(height: 16),
      _collectorProHeader(
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
      if (MediaQuery.textScalerOf(context).scale(16) <= 24) ...[
        const SizedBox(height: 12),
        const _DetailTabs(),
      ],
      const SizedBox(height: 12),
      _collectorInformation(card, name, setName, number, language, rarity),
      const SizedBox(height: 12),
      SectionCard(
        title: 'Pricing / evidence',
        icon: LucideIcons.chartNoAxesCombined,
        children: _pricingRows(context, pricing, providers),
      ),
      if (isFallbackPreview)
        const SectionCard(
          title: 'Detail status',
          icon: LucideIcons.info,
          children: [
            Text(
              'Full card detail is temporarily unavailable. Showing the tapped search result instead.',
            ),
          ],
        ),
    ];
  }

  Widget _collectorProHeader(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // ponytail: preserve the approved split, stack when text scaling needs room.
        final largeText = MediaQuery.textScalerOf(context).scale(16) > 24;
        final wide = constraints.maxWidth >= 360 && !largeText;
        final heroHeight = wide ? 280.0 : (largeText ? 540.0 : 420.0);
        final imageHeight = wide ? 260.0 : (largeText ? 280.0 : 320.0);
        final imageWidth = imageHeight * 5 / 7;
        return SizedBox(
          height: heroHeight,
          child: wide
              ? Row(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _MarketDecisionCard(pricing: pricing),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _CardFactsCard(
                              rarity: _displayRarity(rarity),
                              language: language,
                              finish: _finish(rarity),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
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
                    const SizedBox(height: 12),
                    Expanded(child: _MarketDecisionCard(pricing: pricing)),
                  ],
                ),
        );
      },
    );
  }

  static String _displayRarity(String rarity) => rarity == '—'
      ? (AppConfig.fixtureMode ? 'Unknown / fixture pending' : 'Unknown')
      : rarity;

  Widget _collectorInformation(
    Map<String, dynamic> card,
    String name,
    String setName,
    String number,
    String language,
    String rarity,
  ) {
    return SectionCard(
      title: 'Collector information',
      children: [
        _FactRow(label: 'Name', value: name),
        _FactRow(label: 'Card key', value: textAt(card, 'card_key')),
        _FactRow(label: 'Set', value: setName),
        _FactRow(label: 'Number', value: number),
        _FactRow(label: 'Language', value: language),
        _FactRow(label: 'Rarity', value: _displayRarity(rarity)),
      ],
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
          icon: LucideIcons.trendingUp,
        ),
      );
    } else if (hasFallbackPrice) {
      rows.add(
        _PriceRow(
          label: 'Estimated price',
          price: fp,
          icon: LucideIcons.trendingUp,
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
          icon: LucideIcons.fileCheck,
        ),
        InfoTile(
          label: 'UK evidence',
          value: _evidenceCount(evidence['uk_evidence'], zeroText: 'None yet'),
          icon: LucideIcons.globe,
        ),
        if (source != '—')
          InfoTile(label: 'Source', value: source, icon: LucideIcons.database),
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
          icon: LucideIcons.badgeCheck,
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

  static String _finish(String rarity) => rarity.toLowerCase().contains('holo')
      ? 'Holofoil'
      : (rarity == '—' ? 'Unknown' : 'Standard');
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'Card detail',
      children: [
        Skeletonizer(
          effect: const ShimmerEffect(
            baseColor: Color(0xFF2A2A2D),
            highlightColor: Color(0xFF4A3428),
            duration: Duration(milliseconds: 1250),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loading collector card title',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GlassPanel(
                      padding: EdgeInsets.zero,
                      child: AspectRatio(
                        aspectRatio: 5 / 7,
                        child: ColoredBox(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      children: [
                        GlassPanel(
                          child: SizedBox(
                            height: 92,
                            child: Text('Market price loading'),
                          ),
                        ),
                        SizedBox(height: 10),
                        GlassPanel(
                          child: SizedBox(
                            height: 92,
                            child: Text('Card facts loading'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const GlassPanel(
                child: SizedBox(
                  height: 132,
                  child: Text('Collector information loading'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs();

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      radius: 16,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            _TabLabel('Overview', selected: true),
            _TabLabel('Evidence'),
            _TabLabel('History'),
          ],
        ),
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.name,
    required this.setName,
    required this.number,
  });

  final String name;
  final String setName;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                setName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (number != '—') ...[
              const SizedBox(width: 8),
              Text(number, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel(this.text, {this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 54,
            height: 3,
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDecisionCard extends StatelessWidget {
  const _MarketDecisionCard({required this.pricing});

  final Map<String, dynamic> pricing;

  @override
  Widget build(BuildContext context) {
    final price = CardDetailScreen._priceGlance(pricing);
    final hasPrice = price != 'No pricing yet';
    return _MiniPanel(
      title: 'Market price',
      accent: hasPrice,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasPrice ? price : '—',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: hasPrice ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPrice ? 'Verified market signal' : '0 verified observations',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _CardFactsCard extends StatelessWidget {
  const _CardFactsCard({
    required this.rarity,
    required this.language,
    required this.finish,
  });

  final String rarity;
  final String language;
  final String finish;

  @override
  Widget build(BuildContext context) {
    return _MiniPanel(
      title: 'Card facts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactFact(label: 'Rarity', value: rarity),
          _CompactFact(label: 'Language', value: language),
          const _CompactFact(label: 'Owned', value: 'No'),
          _CompactFact(label: 'Finish', value: finish),
        ],
      ),
    );
  }
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({
    required this.title,
    required this.child,
    this.accent = false,
  });

  final String title;
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      radius: 16,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CompactFact extends StatelessWidget {
  const _CompactFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorActionBar extends StatelessWidget {
  const _CollectorActionBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: FilledButton(onPressed: null, child: Text('Add to inventory')),
        ),
        SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            onPressed: null,
            child: Text('Add to wishlist'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            onPressed: null,
            child: Text('Compare prices'),
          ),
        ),
      ],
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
