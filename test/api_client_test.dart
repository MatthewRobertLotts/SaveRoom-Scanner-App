import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/services/fixture_loader.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';

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

    test('searchCards returns SearchResult list in fixture mode', () async {
      final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
      final results = await client.searchCards('char');
      expect(results, isA<List<SearchResult>>());
      expect(results.isNotEmpty, true);
      expect(results.first.name, 'Charizard ex');
    });

    test('searchCards empty query returns all 5 fixture cards', () async {
      final client = SaveRoomApiClient(fixtureLoader: const FixtureLoader());
      final results = await client.searchCards('');
      expect(results.length, 5);
    });
  });

  group('SearchResult', () {
    test('fromApiItem extracts language from nested object', () {
      final item = <String, dynamic>{
        'card_key': 'en:sv03-223',
        'name': 'Charizard ex',
        'language': <String, dynamic>{'code': 'en', 'name': 'English'},
      };
      final result = SearchResult.fromApiItem(item);
      expect(result.language, 'en');
    });

    test('fromFixtureData extracts language_code from card', () {
      final data = <String, dynamic>{
        'card': <String, dynamic>{'language_code': 'en', 'name': 'Test'},
        'set': <String, dynamic>{},
      };
      final result = SearchResult.fromFixtureData(data);
      expect(result.language, 'en');
    });
  });
}
