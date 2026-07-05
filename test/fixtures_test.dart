import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/services/fixtures.dart';

void main() {
  group('Fixtures', () {
    test('has exactly 5 card keys', () {
      expect(Fixtures.cardKeys.length, 5);
    });

    test('byKey returns data for known card key', () {
      final data = Fixtures.byKey('en:sv03-223');
      expect(data, isA<Map<String, dynamic>>());
      expect(data['data']['card']['name'], 'Charizard ex');
    });

    test('byKey returns fallback for unknown key', () {
      final data = Fixtures.byKey('en:does-not-exist');
      // Falls back to first card (Charizard ex)
      expect(data['data']['card']['name'], 'Charizard ex');
    });

    test('byKey returns correct data for each fixture card', () {
      final expected = {
        'en:sv03-223': 'Charizard ex',
        'en:sv04-234': 'Miraidon ex',
        'en:sv05-191': 'Iono',
        'en:sv07-201': 'Greninja ex',
        'en:sv02-200': 'Giratina V',
      };
      for (final entry in expected.entries) {
        final data = Fixtures.byKey(entry.key);
        expect(
          data['data']['card']['name'],
          entry.value,
          reason: 'Mismatch for ${entry.key}',
        );
      }
    });

    test('jsonString returns valid JSON', () {
      final json = Fixtures.jsonString('en:sv03-223');
      expect(json, isA<String>());
      expect(json.contains('Charizard ex'), true);
    });

    test('every fixture card has required fields', () {
      for (final key in Fixtures.cardKeys) {
        final data = Fixtures.byKey(key);
        final card = data['data']['card'];
        expect(card['name'], isA<String>(), reason: 'name missing in $key');
        expect(card['card_key'], key, reason: 'card_key mismatch in $key');
        expect(
          card['language_code'],
          isA<String>(),
          reason: 'language_code missing in $key',
        );
        expect(data['data']['set'], isA<Map>(), reason: 'set missing in $key');
        expect(
          data['data']['images'],
          isA<Map>(),
          reason: 'images missing in $key',
        );
      }
    });
  });
}
