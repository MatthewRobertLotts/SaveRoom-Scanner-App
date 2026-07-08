import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final baseUrl = args.isNotEmpty ? args.first : 'http://127.0.0.1:8765';
  const queries = [
    'pika',
    'pikachu',
    'chariz',
    'chari',
    'charizard',
    'vile',
    'vilep',
    'vileplume',
    'cynda',
    'cyndaqui',
    'cyndaquil',
    'zzzzzzzz',
  ];

  for (final q in queries) {
    // Simulate the client logic: primary + fuzzy for prefix queries
    final primary = await _searchCards(baseUrl, q);
    print('$q: ${primary.length} rows');
    for (final item in primary.take(5)) {
      print('  ${item['name']} ${item['card_key']}');
    }
  }
}

Future<List<Map<String, dynamic>>> _searchCards(String baseUrl, String query) async {
  // Run primary + fuzzy
  final primary = await _count(
    '$baseUrl/api/v1/search/cards?q=${Uri.encodeComponent(query)}&language_code=en&limit=100',
  );
  final fuzzy = await _count(
    '$baseUrl/api/v1/search/fuzzy?q=${Uri.encodeComponent(query)}&limit=50',
  );
  
  // If primary has results, return them
  if (primary.length >= 8) return primary;
  
  // Extract candidates from fuzzy
  final candidates = _extractCandidates(query, fuzzy);
  if (candidates.isEmpty) return primary;
  
  // Run expanded primary for candidates
  final expandedFutures = candidates.take(2).map((c) => _count(
    '$baseUrl/api/v1/search/cards?q=${Uri.encodeComponent(c)}&language_code=en&limit=100',
  ));
  final expanded = await Future.wait(expandedFutures);
  return expanded.expand((e) => e).toList();
}

List<String> _extractCandidates(String query, List<Map<String, dynamic>> fuzzy) {
  final candidates = <String>{};
  for (final r in fuzzy) {
    final langCode = r['language_code'] as String?;
    final englishName = r['name_english'] as String? ?? '';
    final name = r['name'] as String? ?? '';
    final effectiveName = englishName.isNotEmpty ? englishName : name;
    if (langCode != 'en' && englishName.isEmpty) continue;
    // Check prefix overlap
    final q = query.toLowerCase();
    final n = _normalize(effectiveName);
    if (n.startsWith(q) || q.startsWith(n)) {
      candidates.add(effectiveName);
    }
  }
  return candidates.toList();
}

String _normalize(String s) {
  final lower = s.toLowerCase();
  return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

Future<List<Map<String, dynamic>>> _count(String url) async {
  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return const [];
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  } catch (_) {
    return const [];
  }
}
