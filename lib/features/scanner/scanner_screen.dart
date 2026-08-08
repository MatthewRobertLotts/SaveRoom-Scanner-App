import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/app_config.dart';
import '../../app/app_routes.dart';
import '../../services/fixtures.dart';
import '../../services/saveroom_api_client.dart';
import '../../services/recent_cards.dart';
import '../../widgets/card_thumbnail.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/saveroom_shell.dart';
import '../../widgets/status_pill.dart';
import '../../app/app_theme.dart';

/// ponytail: one screen, two modes. Fixture = local picker. Live = API-backed
/// search with request-ID guard against stale errors.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    SaveRoomApiClient? client,
    bool? forceLiveMode,
    bool? forceFixtureMode,
    this.showScannerLanding = false,
  }) : _client = client,
       _forceLiveMode = forceLiveMode,
       _forceFixtureMode = forceFixtureMode;

  final SaveRoomApiClient? _client;
  final bool? _forceLiveMode;
  final bool? _forceFixtureMode;
  final bool showScannerLanding;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final SaveRoomApiClient _client;
  final _textController = TextEditingController();
  Timer? _debounce;
  int _reqId = 0;

  List<SearchResult> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  bool get _liveMode =>
      widget._forceLiveMode ??
      !(widget._forceFixtureMode ?? AppConfig.fixtureMode);

  @override
  void initState() {
    super.initState();
    _client =
        widget._client ??
        SaveRoomApiClient(forceFixtureMode: widget._forceFixtureMode);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (_liveMode && SearchQuality.shouldSearch(trimmed)) {
      final id = ++_reqId;
      _debounce = Timer(
        const Duration(milliseconds: 240),
        () => _doSearch(trimmed, id),
      );
    } else {
      ++_reqId;
      setState(() {
        _results = [];
        _error = null;
        _searched = false;
        _loading = false;
      });
    }
  }

  Future<void> _doSearch(String query, int reqId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _client.searchCards(query);
      // ponytail: ignore stale responses from earlier requests
      if (reqId != _reqId) return;
      setState(() {
        // ponytail: results already ranked in searchCards (exact > starts-with > contains > English > others)
        _results = results;
        _searched = true;
        _loading = false;
      });
    } catch (e) {
      if (reqId != _reqId) return;
      setState(() {
        // ponytail: friendly error, no raw exception class names
        _error = e is TimeoutException
            ? 'Search timed out. Try again.'
            : 'Search failed. Check the API connection.';
        _loading = false;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liveMode = _liveMode;

    if (widget.showScannerLanding) return _scannerLanding(theme);

    return SaveRoomShell(
      title: 'Search cards',
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: liveMode
                ? 'Search Charizard, SV03, 125…'
                : 'Search cards\u2026',
            prefixIcon: const Icon(LucideIcons.search),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
          ),
          onChanged: liveMode ? _onSearchChanged : _onFixtureQueryChanged,
        ),
        const SizedBox(height: 14),
        _filterChips(),
        const SizedBox(height: 18),
        if (liveMode) ...[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_loading && _results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Updating results…', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          if (_loading && _results.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error == null && _searched && _results.isEmpty)
            _emptyState(
              theme,
              'No cards found',
              'Try a different name or card key',
            )
          else if (_results.isNotEmpty) ...[
            Text(
              '${_results.length} results',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _searchResultsList(theme),
          ] else if (_error == null)
            _emptyState(
              theme,
              'Keep typing',
              'Type at least 3 characters to search',
            ),
        ] else ...[
          _fixtureModeContent(theme),
        ],
      ],
    );
  }

  Widget _scannerLanding(ThemeData theme) {
    final colors = theme.colorScheme;
    return SaveRoomShell(
      title: 'Scan card',
      children: [
        Text(
          'Keep the full card inside the frame',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manual search is ready while camera scanning is being finished.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          strong: true,
          accent: true,
          radius: 22,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              SizedBox(
                height: 430,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScannerFramePainter(colors.primary),
                      ),
                    ),
                    Center(child: _ScannerCardPlaceholder()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIGHTING',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Good  •  Hold steady',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Center(
          child: InkWell(
            key: const Key('scanner-capture-placeholder'),
            borderRadius: BorderRadius.circular(44),
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: saveRoomPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: saveRoomBackground,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 20, height: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChips() {
    return const Wrap(
      spacing: 8,
      children: [
        StatusPill('English', dense: true),
        StatusPill('All sets', dense: true),
        StatusPill('Any rarity', dense: true),
      ],
    );
  }

  void _onFixtureQueryChanged(String value) => setState(() => _results = []);

  Widget _fixtureModeContent(ThemeData theme) {
    final query = _textController.text;
    final filteredKeys = AppConfig.fixtureMode
        ? _filterFixtureKeys(query)
        : <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${filteredKeys.length} results',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (filteredKeys.isEmpty)
          _emptyState(
            theme,
            'No fixture cards found',
            'Try another name or card key',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredKeys.length,
            itemBuilder: (context, i) => _buildSearchResultTile(
              theme,
              SearchResult.fromFixtureData(
                _fixtureData(filteredKeys[i])['data']
                        as Map<String, dynamic>? ??
                    const {},
              ),
              detailArguments: filteredKeys[i],
            ),
          ),
      ],
    );
  }

  List<String> _filterFixtureKeys(String query) {
    if (query.isEmpty) return Fixtures.cardKeys;
    final q = query.toLowerCase();
    return Fixtures.cardKeys.where((key) {
      final card = Fixtures.byKey(key)['data']?['card'];
      final name = (card?['name'] ?? '').toString().toLowerCase();
      final code = (card?['card_key'] ?? '').toString().toLowerCase();
      final number = (card?['collector_number'] ?? card?['number'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(q) || code.contains(q) || number.contains(q);
    }).toList();
  }

  Map<String, dynamic> _fixtureData(String key) => Fixtures.byKey(key);

  Widget _searchResultsList(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final r = _results[i];
        return _buildSearchResultTile(theme, r);
      },
    );
  }

  Widget _buildSearchResultTile(
    ThemeData theme,
    SearchResult r, {
    Object? detailArguments,
  }) {
    final tile = GlassPanel(
      margin: const EdgeInsets.only(bottom: 14),
      radius: 18,
      onTap: () {
        RecentlyViewed.add(r);
        Navigator.pushNamed(
          context,
          AppRoutes.cardDetail,
          arguments:
              detailArguments ??
              CardDetailArgs(cardKey: r.cardKey, fallback: r),
        );
      },
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardThumbnail(
            imageUrls: r.imageUrlCandidates,
            cardName: r.name,
            width: 84,
            height: 118,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _resultSubtitle(r),
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                if (r.rarity != null && r.rarity != '—')
                  StatusPill(r.rarity!, dense: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            LucideIcons.chevronRight,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
    return tile;
  }

  String _resultSubtitle(SearchResult r) {
    final parts = <String>[];
    if (r.displayText.isNotEmpty && r.displayText != '—') {
      parts.add(r.displayText);
    }
    if (r.language != null && r.language != 'en') {
      parts.add(r.language!);
    }
    return parts.isEmpty ? '' : parts.join(' · ');
  }

  Widget _emptyState(ThemeData theme, String title, String subtitle) {
    return GlassPanel(
      margin: const EdgeInsets.only(top: 12),
      radius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(
            LucideIcons.searchX,
            size: 44,
            color: theme.colorScheme.primary.withValues(alpha: 0.74),
          ),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.84,
      height: size.height * 0.80,
    );
    final corner = rect.width * 0.16;
    for (final p in [
      (rect.topLeft, Offset(corner, 0), Offset(0, corner)),
      (rect.topRight, Offset(-corner, 0), Offset(0, corner)),
      (rect.bottomLeft, Offset(corner, 0), Offset(0, -corner)),
      (rect.bottomRight, Offset(-corner, 0), Offset(0, -corner)),
    ]) {
      canvas.drawLine(p.$1, p.$1 + p.$2, paint);
      canvas.drawLine(p.$1, p.$1 + p.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ScannerCardPlaceholder extends StatelessWidget {
  _ScannerCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      widthFactor: 0.50,
      child: AspectRatio(
        aspectRatio: 5 / 7,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: saveRoomRaisedSurface,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.55),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 86, height: 10, color: colors.outline),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 6,
                  color: colors.outline,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 6,
                  color: colors.outline,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(width: 44, height: 8, color: colors.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
