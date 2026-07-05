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

  group('SearchResult ranking', () {
    List<SearchResult> rankResults(List<SearchResult> items, String query) {
      final q = query.toLowerCase();
      items.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        final aScore =
            (aName == q ? 4 : 0) +
            (aName.startsWith(q) ? 3 : 0) +
            (aName.contains(q) ? 2 : 0) +
            (a.language == 'en' ? 1 : 0);
        final bScore =
            (bName == q ? 4 : 0) +
            (bName.startsWith(q) ? 3 : 0) +
            (bName.contains(q) ? 2 : 0) +
            (b.language == 'en' ? 1 : 0);
        return bScore.compareTo(aScore);
      });
      return items;
    }

    test('English exact match ranks first', () {
      final items = [
        SearchResult(
          cardKey: 'de:x',
          name: 'Pikachu',
          setText: '',
          language: 'de',
        ),
        SearchResult(
          cardKey: 'en:x',
          name: 'Pikachu',
          setText: '',
          language: 'en',
        ),
      ];
      final ranked = rankResults(items, 'Pikachu');
      expect(ranked.first.language, 'en');
    });

    test('English starts-with beats non-English contains', () {
      final items = [
        SearchResult(
          cardKey: 'de:x',
          name: 'Pikachu',
          setText: '',
          language: 'de',
        ),
        SearchResult(
          cardKey: 'en:x',
          name: 'Pika',
          setText: '',
          language: 'en',
        ),
      ];
      final ranked = rankResults(items, 'Pika');
      expect(ranked.first.language, 'en');
      expect(ranked.first.name, 'Pika');
    });

    test('non-English results are retained after English', () {
      final items = [
        SearchResult(
          cardKey: 'de:x',
          name: 'Pikachu',
          setText: '',
          language: 'de',
        ),
        SearchResult(
          cardKey: 'en:x',
          name: 'Pikachu',
          setText: '',
          language: 'en',
        ),
        SearchResult(
          cardKey: 'fr:x',
          name: 'Pikachu',
          setText: '',
          language: 'fr',
        ),
      ];
      final ranked = rankResults(items, 'Pikachu');
      expect(ranked.length, 3);
      expect(ranked[0].language, 'en');
    });
  });
}
