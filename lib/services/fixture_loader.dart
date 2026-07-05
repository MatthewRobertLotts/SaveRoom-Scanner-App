import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'fixtures.dart';

/// ponytail: loadFixture still loads from assets for the JSON fixture file;
/// loadCardDetailByKey uses inline Fixtures map (no asset dependency).
class FixtureLoader {
  const FixtureLoader();

  static const basePath = 'assets/fixtures/v12_2_pos';

  Future<Map<String, dynamic>> loadJson(String fileName) async {
    final raw = await rootBundle.loadString('$basePath/$fileName');
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw FormatException('Fixture $fileName is not a JSON object');
  }

  /// Load the original Charizard ex fixture from the asset file.
  Future<Map<String, dynamic>> loadCardDetail() =>
      loadJson('card_detail_response.json');

  /// Load a specific fixture card by key from the inline map.
  Map<String, dynamic> loadCardDetailByKey(String cardKey) =>
      Fixtures.byKey(cardKey);

  /// All available fixture card keys.
  List<String> get fixtureKeys => Fixtures.cardKeys;
}

Map<String, dynamic> asMap(Object? value) =>
    value is Map<String, dynamic> ? value : const {};
List<dynamic> asList(Object? value) =>
    value is List<dynamic> ? value : const [];
String textAt(Map<String, dynamic> map, String key, [String fallback = '—']) {
  final value = map[key];
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String joinPresent(
  Iterable<String> values, {
  String separator = ' / ',
  String fallback = '—',
}) {
  final kept = values.where((v) => v.trim().isNotEmpty && v != '—').toList();
  return kept.isEmpty ? fallback : kept.join(separator);
}
