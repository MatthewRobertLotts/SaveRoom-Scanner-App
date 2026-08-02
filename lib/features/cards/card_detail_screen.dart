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
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({
    super.key,
    SaveRoomApiClient? client,
    this.forceFixtureMode,
  }) : _client = client;

  final SaveRoomApiClient? _client;
  final bool? forceFixtureMode;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  String? _cardKey;
  SearchResult? _fallback;
  SaveRoomApiClient? _client;
  Future<Map<String, dynamic>>? _detailFuture;

  SaveRoomApiClient get _apiClient => _client ??=
      widget._client ??
      SaveRoomApiClient(
        fixtureLoader: const FixtureLoader(),
        forceFixtureMode: widget.forceFixtureMode,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_detailFuture != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    _fallback = args is CardDetailArgs ? args.fallback : null;
    _cardKey = switch (args) {
      CardDetailArgs(:final cardKey) => cardKey,
      String value => value,
      _ => 'en:sv03-223',
    };
    _detailFuture = _apiClient.getCardDetail(_cardKey!);
  }

  void _selectVariant(SearchResult result) {
    if (result.cardKey.isEmpty || result.cardKey == _cardKey) return;
    setState(() {
      _cardKey = result.cardKey;
      _fallback = result;
      _detailFuture = _apiClient.getCardDetail(result.cardKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (_fallback != null && _fallback!.hasFallbackDetail) {
            return SaveRoomShell(
              title: 'Card detail',
              children: _content(
                context,
                _fallback!.toFallbackDetailResponse(),
                isFallbackPreview: true,
              ),
            );
          }
          return _unavailable(context, _cardKey ?? '—');
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
        client: _apiClient,
        selectedCardKey: _cardKey ?? textAt(card, 'card_key'),
        data: data,
        name: name,
        setName: setName,
        number: number,
        language: language,
        rarity: rarity,
        pricing: pricing,
        isFallbackPreview: isFallbackPreview,
        onVariantSelected: _selectVariant,
      ),
      const SizedBox(height: 12),
      _variantSelector(language),
      const SizedBox(height: 12),
      _bentoGrid(
        context,
        setName,
        number,
        language,
        name,
        _displayRarity(rarity),
        pricing,
      ),
      const SizedBox(height: 12),
      SectionCard(
        title: 'Pricing / evidence',
        icon: Icons.query_stats_outlined,
        children: _pricingRows(context, pricing, providers),
      ),
      const _HeroActions(),
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
    required SaveRoomApiClient client,
    required String selectedCardKey,
    required Map<String, dynamic> data,
    required String name,
    required String setName,
    required String number,
    required String language,
    required String rarity,
    required Map<String, dynamic> pricing,
    required bool isFallbackPreview,
    required ValueChanged<SearchResult> onVariantSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ponytail: Variant Explorer top, Bento facts below. No squeezed side rail.
        final heroHeight = MediaQuery.sizeOf(context).height * 0.42;
        final imageHeight = (heroHeight - 70).clamp(180.0, 330.0);
        final imageWidth = imageHeight * 5 / 7;
        return SizedBox(
          height: heroHeight,
          child: Column(
            children: [
              Expanded(
                child: _VariantImagePager(
                  client: client,
                  selectedCardKey: selectedCardKey,
                  name: name,
                  data: data,
                  imageWidth: imageWidth,
                  imageHeight: imageHeight,
                  onVariantSelected: onVariantSelected,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Selected printing',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }

  static String _displayRarity(String rarity) => rarity == '—'
      ? (AppConfig.fixtureMode ? 'Unknown / fixture pending' : 'Unknown')
      : rarity;

  Widget _variantSelector(String language) {
    return Row(
      children: [
        Expanded(child: _SelectorChip(label: language, selected: true)),
        const SizedBox(width: 8),
        const Expanded(child: _SelectorChip(label: 'Alt language')),
        const SizedBox(width: 8),
        const Expanded(child: _SelectorChip(label: 'Reverse')),
      ],
    );
  }

  Widget _bentoGrid(
    BuildContext context,
    String setName,
    String number,
    String language,
    String name,
    String rarity,
    Map<String, dynamic> pricing,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BentoTile(
                title: 'Identity',
                lines: [name, setName, number, language],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                title: 'Market',
                lines: [_priceGlance(pricing), rarity],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BentoTile(
                title: 'Collection',
                lines: ['Not owned', 'Inventory coming later'],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                title: 'Printings',
                lines: ['Swipe card image', 'Same-name variants'],
              ),
            ),
          ],
        ),
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

class _VariantImagePager extends StatefulWidget {
  const _VariantImagePager({
    required this.client,
    required this.selectedCardKey,
    required this.name,
    required this.data,
    required this.imageWidth,
    required this.imageHeight,
    required this.onVariantSelected,
  });

  final SaveRoomApiClient client;
  final String selectedCardKey;
  final String name;
  final Map<String, dynamic> data;
  final double imageWidth;
  final double imageHeight;
  final ValueChanged<SearchResult> onVariantSelected;

  @override
  State<_VariantImagePager> createState() => _VariantImagePagerState();
}

class _VariantImagePagerState extends State<_VariantImagePager> {
  late Future<List<SearchResult>> _future;
  int _index = 0;
  double _dragDx = 0;

  @override
  void initState() {
    super.initState();
    _future = widget.client.searchCards(widget.name);
  }

  @override
  void didUpdateWidget(covariant _VariantImagePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name || oldWidget.client != widget.client) {
      _index = 0;
      _future = widget.client.searchCards(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: _future,
      builder: (context, snapshot) {
        final variants = _variants(snapshot.data ?? const []);
        final currentIndex = variants.indexWhere(
          (r) => r.cardKey == widget.selectedCardKey,
        );
        _index = _index.clamp(0, variants.length - 1);
        final shownIndex = currentIndex < 0 ? _index : currentIndex;
        final variant = variants[shownIndex];
        final pageData = variant.cardKey == widget.selectedCardKey
            ? widget.data
            : asMap(variant.toFallbackDetailResponse()['data']);
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onHorizontalDragStart: (_) => _dragDx = 0,
              onHorizontalDragUpdate: (details) => _dragDx += details.delta.dx,
              onHorizontalDragEnd: (details) {
                if (variants.length < 2) return;
                if (_dragDx.abs() < 60) return;
                final next = _dragDx < 0
                    ? (shownIndex + 1).clamp(0, variants.length - 1)
                    : (shownIndex - 1).clamp(0, variants.length - 1);
                if (next == shownIndex) return;
                setState(() => _index = next);
                widget.onVariantSelected(variants[next]);
              },
              child: Center(
                child: SizedBox(
                  width: widget.imageWidth,
                  child: CardImagePanel.fromData(
                    pageData,
                    imageHeight: widget.imageHeight,
                    showTitle: false,
                    showMetadata: false,
                  ),
                ),
              ),
            ),
            if (variants.length > 1)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    '${shownIndex + 1} of ${variants.length} printings · swipe',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<SearchResult> _variants(List<SearchResult> results) {
    final current = SearchResult(
      cardKey: widget.selectedCardKey,
      name: widget.name,
      setText: 'Selected printing',
      rawItem: widget.data,
    );
    final exact = results.where((r) => _sameName(r.name, widget.name)).toList();
    final byKey = <String, SearchResult>{widget.selectedCardKey: current};
    for (final r in exact) {
      if (r.cardKey.isNotEmpty) byKey[r.cardKey] = r;
    }
    return byKey.values.toList();
  }

  static bool _sameName(String a, String b) => _norm(a) == _norm(b);
  static String _norm(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

class _SelectorChip extends StatelessWidget {
  const _SelectorChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.38)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
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
