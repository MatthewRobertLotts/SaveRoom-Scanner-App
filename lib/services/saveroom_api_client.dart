import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'fixture_loader.dart';
import 'fixtures.dart';

/// ponytail: unified result type for both fixture and API search results.
class SearchResult {
  final String cardKey;
  final String name;
  final String setText;
  final String? rarity;
  final String? language;
  final String source;

  const SearchResult({
    required this.cardKey,
    required this.name,
    required this.setText,
    this.rarity,
    this.language,
    this.source = 'fixture',
  });

  /// Construct from fixture card data (uses the `data.card` / `data.set` shape).
  factory SearchResult.fromFixtureData(Map<String, dynamic> data) {
    final card = (data['card'] as Map<String, dynamic>?) ?? const {};
    final set = (data['set'] as Map<String, dynamic>?) ?? const {};
    return SearchResult(
      cardKey: card['card_key'] as String? ?? '',
      name: card['name'] as String? ?? '',
      setText: '${set['name'] ?? ''} / ${card['collector_number'] ?? ''}',
      rarity: card['rarity'] as String?,
      language: card['language_code'] as String?,
      source: 'fixture',
    );
  }

  /// Construct from API search response item. Handles both cards/search
  /// (has card_key, set map) and fuzzy (has card_id + language_code, no set).
  factory SearchResult.fromApiItem(
    Map<String, dynamic> item, {
    String source = 'api',
  }) {
    final lang = item['language'];
    final langCode = lang is String
        ? lang
        : (lang is Map ? (lang)['code'] as String? : null) ??
              item['language_code'] as String?;
    final cardKey =
        item['card_key'] as String? ??
        _buildKey(item['card_id'] as String?, item['language_code'] as String?);
    // ponytail: build set text from whatever the endpoint provides.
    // autocomplete returns 'set' as a flat string, not a map.
    String setText;
    final rawSet = item['set'];
    if (rawSet is String) {
      setText = rawSet;
    } else if (rawSet is Map) {
      final name = (rawSet)['name'] as String? ?? '';
      final code = (rawSet)['set_code'] as String? ?? '';
      final num = item['collector_number'] as String? ?? '';
      setText = joinPresent([name, code, num]);
    } else {
      // fuzzy: no set info at all, use card_id or language
      final cid = item['card_id'] as String?;
      final lc = item['language_code'] as String?;
      setText = cid ?? lc ?? '';
    }
    return SearchResult(
      cardKey: cardKey,
      name: item['name'] as String? ?? '',
      setText: setText,
      rarity: item['rarity'] as String?,
      language: langCode,
      source: source,
    );
  }

  static String _buildKey(String? cardId, String? lang) {
    if (cardId == null || cardId.isEmpty) return '';
    if (lang == null || lang.isEmpty) return cardId;
    return '$lang:$cardId';
  }

  /// ponytail: safe display text — never show bare / or null/null.
  /// Falls back to card key or "Tap to view" when metadata is sparse.
  String get displayText {
    final st = setText;
    if (st.isEmpty || st == '/') {
      return cardKey.isNotEmpty ? cardKey : 'Tap to view';
    }
    return st;
  }
}

class SearchQuality {
  const SearchQuality._();

  static bool isStrongNameMatch(SearchResult r, String q) {
    final name = r.name.toLowerCase();
    final query = q.toLowerCase();
    return name == query || name.startsWith(query) || name.contains(query);
  }

  static int score(SearchResult r, String q) {
    final query = q.toLowerCase();
    final name = r.name.toLowerCase();
    final key = r.cardKey.toLowerCase();
    final sourceScore = switch (r.source) {
      'primary' => 80,
      'autocomplete' => 60,
      'fuzzy' => 20,
      _ => 0,
    };
    return (name == query ? 1000 : 0) +
        (name.startsWith(query) ? 700 : 0) +
        (name.contains(query) ? 400 : 0) +
        (key.contains(query) ? 200 : 0) +
        (r.language == 'en' ? 100 : -50) +
        sourceScore;
  }

  static List<SearchResult> rankAndFilterNoise(
    Iterable<SearchResult> results,
    String query,
  ) {
    final q = query.toLowerCase();
    final seen = <String>{};
    final all = results.toList();
    final hasStrong = all.any((r) => isStrongNameMatch(r, q));
    final deduped = <SearchResult>[];
    for (final r in all) {
      if (r.source == 'fuzzy' && !isStrongNameMatch(r, q)) {
        continue;
      }
      if (r.source == 'autocomplete' && hasStrong && !isStrongNameMatch(r, q)) {
        continue;
      }
      if (r.cardKey.isNotEmpty && seen.add(r.cardKey)) {
        deduped.add(r);
      }
    }
    deduped.sort((a, b) => score(b, q).compareTo(score(a, q)));
    return deduped;
  }
}

class CardImageResolver {
  const CardImageResolver._();

  static List<String> candidatesFromDetailData(
    Map<String, dynamic> data, {
    String apiBaseUrl = AppConfig.apiBaseUrl,
    Map<String, dynamic>? imageMetadata,
  }) {
    final card = _asStringMap(data['card']);
    final detailImages = _asStringMap(data['images']);
    final cardImages = _asStringMap(card['images']);
    final metadataData = _asStringMap(imageMetadata?['data']);
    final metadataImages = metadataData.isNotEmpty
        ? metadataData
        : _asStringMap(imageMetadata);
    final urls = <String>[];

    void add(Object? value) {
      final raw = value?.toString().trim();
      if (raw == null || raw.isEmpty || raw == '—') return;
      for (final url in _normalizeUrl(raw, apiBaseUrl)) {
        if (!urls.contains(url)) urls.add(url);
      }
    }

    for (final map in [metadataImages, detailImages, cardImages, card]) {
      add(map['signed_image_url']);
      add(map['local_display_image_url']);
      add(map['primary_image_url']);
      add(map['display_image_url']);
      add(map['exact_image_url']);
      add(map['image_url']);
      add(map['url']);
    }
    return urls;
  }

  static List<String> _normalizeUrl(String raw, String apiBaseUrl) {
    final apiBase = Uri.parse(apiBaseUrl);
    if (raw.startsWith('/media/') || raw.startsWith('file://')) {
      return const [];
    }
    if (raw.startsWith('/')) {
      return [_joinApiBase(apiBaseUrl, raw)];
    }
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      return [_joinApiBase(apiBaseUrl, '/$raw')];
    }
    final uri = Uri.parse(raw);
    final rewritten = (uri.host == '127.0.0.1' || uri.host == 'localhost')
        ? uri.replace(
            scheme: apiBase.scheme,
            host: apiBase.host,
            port: apiBase.port,
          )
        : uri;
    final url = rewritten.toString();
    if (_isBareTcgdexAsset(rewritten)) {
      final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      return ['$base/high.png', '$base/low.png', url];
    }
    return [url];
  }

  static bool _isBareTcgdexAsset(Uri uri) {
    if (uri.host != 'assets.tcgdex.net') return false;
    final path = uri.path.toLowerCase();
    return !path.endsWith('.png') &&
        !path.endsWith('.jpg') &&
        !path.endsWith('.jpeg') &&
        !path.endsWith('.webp') &&
        !path.endsWith('/high.png') &&
        !path.endsWith('/low.png');
  }

  static String _joinApiBase(String apiBaseUrl, String path) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    return '$base$path';
  }

  static Map<String, dynamic> _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }
}

class SaveRoomApiClient {
  SaveRoomApiClient({
    FixtureLoader fixtureLoader = const FixtureLoader(),
    http.Client? httpClient,
  }) : _fixtureLoader = fixtureLoader,
       _httpClient = httpClient ?? http.Client();

  final FixtureLoader _fixtureLoader;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> getCardDetail(String cardKey) async {
    if (AppConfig.fixtureMode) {
      return _fixtureLoader.loadCardDetailByKey(cardKey);
    }
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/api/v1/cards/${Uri.encodeComponent(cardKey)}/detail',
    );
    final response = await _httpClient.get(uri);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return _withImageCandidates(cardKey, decoded);
      }
      throw FormatException('Card detail response is not a JSON object');
    }
    throw Exception(
      'API error ${response.statusCode}: ${response.reasonPhrase}',
    );
  }

  Future<Map<String, dynamic>> _withImageCandidates(
    String cardKey,
    Map<String, dynamic> detail,
  ) async {
    final data = detail['data'];
    if (data is! Map<String, dynamic>) return detail;
    final metadata = await _getImageMetadata(cardKey);
    final candidates = CardImageResolver.candidatesFromDetailData(
      data,
      imageMetadata: metadata,
    );
    final images = Map<String, dynamic>.from(
      (data['images'] as Map<String, dynamic>?) ?? const {},
    );
    images['image_url_candidates'] = candidates;
    images['resolved_image_url'] = candidates.isNotEmpty
        ? candidates.first
        : null;
    detail['data'] = Map<String, dynamic>.from(data)..['images'] = images;
    return detail;
  }

  Future<Map<String, dynamic>?> _getImageMetadata(String cardKey) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/v1/images/cards/${Uri.encodeComponent(cardKey)}',
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getHealth() async {
    if (AppConfig.fixtureMode) {
      return const <String, dynamic>{
        'data': <String, dynamic>{
          'ok': true,
          'service': 'fixture-mode',
          'auth': <String, dynamic>{'api_key_required': false},
        },
      };
    }
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/health');
    final response = await _httpClient.get(uri);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Health response is not a JSON object');
    }
    throw Exception('Health check failed: ${response.statusCode}');
  }

  Future<List<SearchResult>> searchCards(String query) async {
    if (AppConfig.fixtureMode) {
      final q = query.toLowerCase();
      return Fixtures.cardKeys
          .where((key) {
            final result = SearchResult.fromFixtureData(
              Fixtures.byKey(key)['data'] as Map<String, dynamic>? ?? const {},
            );
            return result.name.toLowerCase().contains(q) ||
                result.cardKey.toLowerCase().contains(q);
          })
          .map(
            (key) => SearchResult.fromFixtureData(
              Fixtures.byKey(key)['data'] as Map<String, dynamic>? ?? const {},
            ),
          )
          .toList();
    }

    final q = query.toLowerCase();
    // ponytail: always merge primary + autocomplete + fuzzy. Every helper
    // catches internally so fallback failures cannot break primary results.
    final primary = await _searchPrimary(query);
    final auto = await _searchAutocomplete(query);
    final fuzzy = await _searchFuzzy(query);

    return SearchQuality.rankAndFilterNoise([...primary, ...auto, ...fuzzy], q);
  }

  Future<List<SearchResult>> _searchPrimary(String query) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/v1/search/cards'
        '?q=${Uri.encodeComponent(query)}&language_code=en&limit=200',
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(response.body) as Map<String, dynamic>? ?? {};
        final data = decoded['data'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map((item) => SearchResult.fromApiItem(item, source: 'primary'))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<SearchResult>> _searchAutocomplete(String query) async {
    if (query.length < 2) return [];
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/v1/search/autocomplete'
        '?q=${Uri.encodeComponent(query)}&limit=10',
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(response.body) as Map<String, dynamic>? ?? {};
        final data = decoded['data'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map(
                (item) =>
                    SearchResult.fromApiItem(item, source: 'autocomplete'),
              )
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<SearchResult>> _searchFuzzy(String query) async {
    if (query.length < 3) return [];
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/v1/search/fuzzy'
        '?q=${Uri.encodeComponent(query)}&limit=10',
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(response.body) as Map<String, dynamic>? ?? {};
        final data = decoded['data'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map((item) => SearchResult.fromApiItem(item, source: 'fuzzy'))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> legacySearch(String query) async {
    // ponytail: kept for backward compat; prefer searchCards above.
    if (AppConfig.fixtureMode) {
      return [await _fixtureLoader.loadCardDetail()];
    }
    throw UnimplementedError('legacySearch is replaced by searchCards.');
  }

  Future<Map<String, dynamic>> getCurrentUserEntitlements() {
    throw UnimplementedError('App user entitlements are backend v12.3 work.');
  }
}
