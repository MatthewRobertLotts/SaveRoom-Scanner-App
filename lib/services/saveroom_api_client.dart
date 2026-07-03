import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'fixture_loader.dart';

class SaveRoomApiClient {
  SaveRoomApiClient({
    FixtureLoader fixtureLoader = const FixtureLoader(),
    http.Client? httpClient,
  }) : _fixtureLoader = fixtureLoader,
       _httpClient = httpClient ?? http.Client();

  final FixtureLoader _fixtureLoader;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> getCardDetail(String cardKey) async {
    if (AppConfig.fixtureMode) return _fixtureLoader.loadCardDetail();
    // ponytail: single endpoint, upgrade when batch is needed
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

  // ponytail: searchCards and getCurrentUserEntitlements stubs kept for interface shape
  Future<List<Map<String, dynamic>>> searchCards(String query) async {
    if (AppConfig.fixtureMode) return [await _fixtureLoader.loadCardDetail()];
    throw UnimplementedError('Real API search is not implemented in v0.2.');
  }

  Future<Map<String, dynamic>> getCurrentUserEntitlements() {
    throw UnimplementedError('App user entitlements are backend v12.3 work.');
  }
}
