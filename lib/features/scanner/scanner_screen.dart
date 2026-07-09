import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../app/app_routes.dart';
import '../../services/fixtures.dart';
import '../../services/saveroom_api_client.dart';
import '../../services/recent_cards.dart';
import '../../widgets/card_thumbnail.dart';
import '../../widgets/saveroom_shell.dart';
import '../../widgets/status_pill.dart';

/// ponytail: one screen, two modes. Fixture = local picker. Live = API-backed
/// search with request-ID guard against stale errors.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    SaveRoomApiClient? client,
    bool? forceLiveMode,
  }) : _client = client,
       _forceLiveMode = forceLiveMode;

  final SaveRoomApiClient? _client;
  final bool? _forceLiveMode;

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

  bool get _liveMode => widget._forceLiveMode ?? !AppConfig.fixtureMode;

  @override
  void initState() {
    super.initState();
    _client = widget._client ?? SaveRoomApiClient();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (_liveMode && query.length >= 3) {
      final id = ++_reqId;
      _debounce = Timer(
        const Duration(milliseconds: 240),
        () => _doSearch(query, id),
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

    return SaveRoomShell(
      title: liveMode ? 'Search live API cards' : 'Choose a fixture card',
      children: [
        Text(
          liveMode
              ? 'Live API mode — search the Zima API'
              : 'Fixture mode — camera/OCR not enabled yet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: liveMode
                ? 'Search by name, set, number, or card key'
                : 'Search cards\u2026',
            prefixIcon: const Icon(Icons.search),
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
        const SizedBox(height: 8),
        if (liveMode) ...[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
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
          else if (_results.isNotEmpty)
            _searchResultsList(theme)
          else if (_error == null)
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
          '${filteredKeys.length} of ${5} cards',
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredKeys.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _buildResultTile(
              theme,
              SearchResult.fromFixtureData(
                _fixtureData(filteredKeys[i])['data']
                        as Map<String, dynamic>? ??
                    const {},
              ),
              filteredKeys[i],
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
      return name.contains(q) || code.contains(q);
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

  Widget _buildSearchResultTile(ThemeData theme, SearchResult r) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: InkWell(
        onTap: () {
          RecentlyViewed.add(r);
          Navigator.pushNamed(
            context,
            AppRoutes.cardDetail,
            arguments: CardDetailArgs(cardKey: r.cardKey, fallback: r),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CardThumbnail(imageUrls: r.imageUrlCandidates, cardName: r.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resultSubtitle(r),
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (r.rarity != null && r.rarity != '—')
                StatusPill(r.rarity!, dense: true),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildResultTile(
    ThemeData theme,
    SearchResult result,
    String cardKey,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.style, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        result.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(result.displayText, style: theme.textTheme.bodySmall),
      trailing: result.rarity != null
          ? Chip(
              label: Text(result.rarity!, style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.cardDetail,
        arguments: cardKey,
      ),
    );
  }

  Widget _emptyState(ThemeData theme, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
