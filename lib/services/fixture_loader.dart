import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class FixtureLoader {
  const FixtureLoader();

  static const _basePath = 'assets/fixtures/v12_2_pos';

  Future<Map<String, dynamic>> loadJson(String fileName) async {
    final raw = await rootBundle.loadString('$_basePath/$fileName');
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw FormatException('Fixture $fileName is not a JSON object');
  }

  Future<Map<String, dynamic>> loadCardDetail() =>
      loadJson('card_detail_response.json');
}

Map<String, dynamic> asMap(Object? value) =>
    value is Map<String, dynamic> ? value : const {};
List<dynamic> asList(Object? value) =>
    value is List<dynamic> ? value : const [];
String textAt(Map<String, dynamic> map, String key, [String fallback = '—']) {
  final value = map[key];
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}
