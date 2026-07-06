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

  const SearchResult({
    required this.cardKey,
    required this.name,
    required this.setText,
    this.rarity,
    this.language,
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
    );
  }

  /// Construct from API search response item.
  factory SearchResult.fromApiItem(Map<String, dynamic> item) {
    final set = (item['set'] as Map<String, dynamic>?) ?? const {};
    final lang = (item['language'] as Map<String, dynamic>?) ?? const {};
    return SearchResult(
      cardKey: item['card_key'] as String? ?? '',
      name: item['name'] as String? ?? '',
      setText: '${set['name'] ?? ''} / ${item['collector_number'] ?? ''}',
      rarity: item['rarity'] as String?,
      language: lang['code'] as String? ?? item['language_code'] as String?,
    );
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
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Card detail response is not a JSON object');
    }
    throw Exception(
      'API error ${response.statusCode}: ${response.reasonPhrase}',
    );
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
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/api/v1/search/cards'
      '?q=${Uri.encodeComponent(query)}&language_code=en&limit=200',
    );
    final response = await _httpClient
        .get(uri)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final data = decoded['data'];
      if (data is List) {
        final results = data
            .cast<Map<String, dynamic>>()
            .map((item) => SearchResult.fromApiItem(item))
            .toList();
        // ponytail: client-side ranking: exact > starts-with > contains > English > others
        final q = query.toLowerCase();
        results.sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          final aExact = aName == q ? 4 : 0;
          final bExact = bName == q ? 4 : 0;
          final aStarts = aName.startsWith(q) ? 3 : 0;
          final bStarts = bName.startsWith(q) ? 3 : 0;
          final aContains = aName.contains(q) ? 2 : 0;
          final bContains = bName.contains(q) ? 2 : 0;
          final aScore =
              aExact + aStarts + aContains + (a.language == 'en' ? 1 : 0);
          final bScore =
              bExact + bStarts + bContains + (b.language == 'en' ? 1 : 0);
          return bScore.compareTo(aScore);
        });
        return results;
      }
      // ponytail: primary search empty → try fuzzy fallback
      final fuzzy = await _searchFuzzy(query);
      if (fuzzy.isNotEmpty) {
        final seen = <String>{};
        return fuzzy.where((r) => seen.add(r.cardKey)).toList();
      }
      return [];
    }
    throw Exception('Search failed: HTTP ${response.statusCode}');
  }

  Future<List<SearchResult>> _searchFuzzy(String query) async {
    // ponytail: fuzzy uses trigram similarity, catches misspellings and partials
    if (query.length < 3) return [];
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/api/v1/search/fuzzy'
      '?q=${Uri.encodeComponent(query)}&limit=10',
    );
    final response = await _httpClient
        .get(uri)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final data = decoded['data'];
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map((item) => SearchResult.fromApiItem(item))
            .toList();
      }
    }
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
