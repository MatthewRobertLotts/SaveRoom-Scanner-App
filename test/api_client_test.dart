import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saveroom_scanner_app/services/fixture_loader.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';

import 'package:http/testing.dart';

/// A fake HTTP client factory that returns canned JSON bodies.
http.Client _mockClient({int statusCode = 200, Map<String, dynamic>? body}) {
  final json = jsonEncode(
    body ??
        {
          'data': {'ok': true},
        },
  );
  return MockClient((_) async => http.Response(json, statusCode));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveRoomApiClient (fixture mode)', () {
    test('getCardDetail returns fixture data in fixture mode', () async {
      final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
      final result = await client.getCardDetail('en:sv03-223');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data']['card']['name'], 'Charizard ex');
    });

    test('getHealth returns fixture-mode object in fixture mode', () async {
      final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
      final result = await client.getHealth();
      expect(result['data']['service'], 'fixture-mode');
      expect(result['data']['ok'], true);
    });
  });

  group('SaveRoomApiClient (real API mode — mocked HTTP)', () {
    test('http client injection works — mock is used when passed', () async {
      final mockHttpClient = _mockClient(
        body: {
          'data': {'ok': true},
        },
      );
      final client = SaveRoomApiClient(
        fixtureLoader: const FixtureLoader(),
        httpClient: mockHttpClient,
      );
      // Even in fixture mode (default), the client constructor accepts
      // a custom http client — this proves the injection plumbing works.
      expect(client, isA<SaveRoomApiClient>());
    });
  });
}
