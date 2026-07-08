import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/features/cards/card_detail_screen.dart';
import 'package:saveroom_scanner_app/services/fixture_loader.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';

class _FakeDetailClient extends SaveRoomApiClient {
  _FakeDetailClient(this.loader) : super(fixtureLoader: const FixtureLoader());

  final Future<Map<String, dynamic>> Function(String cardKey) loader;

  @override
  Future<Map<String, dynamic>> getCardDetail(String cardKey) => loader(cardKey);
}

Map<String, dynamic> _detail(String name, String key) => <String, dynamic>{
  'data': <String, dynamic>{
    'card': <String, dynamic>{
      'card_key': key,
      'name': name,
      'language_code': 'en',
      'collector_number': '25',
    },
    'set': <String, dynamic>{'name': 'Vivid Voltage', 'set_code': 'swsh4'},
    'images': <String, dynamic>{},
    'pricing': <String, dynamic>{},
    'commercial': <String, dynamic>{},
    'provider_status': <String, dynamic>{},
  },
  'metadata': <String, dynamic>{
    'contract': 'app-ready-card-detail',
    'api_version': 'v12.2.0',
    'sanitized': true,
  },
};

Widget _screen({required SaveRoomApiClient client, Object? args}) {
  return MaterialApp(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      settings: RouteSettings(arguments: args),
      builder: (_) => CardDetailScreen(client: client),
    ),
  );
}

void main() {
  testWidgets('full detail success uses full detail instead of fallback', (
    tester,
  ) async {
    final client = _FakeDetailClient(
      (_) async => _detail('Full Detail Name', 'en:swsh4-25'),
    );
    const fallback = SearchResult(
      cardKey: 'en:swsh4-25',
      name: 'Fallback Name',
      setText: 'Vivid Voltage / swsh4 / 25',
      language: 'en',
      source: 'primary',
    );

    await tester.pumpWidget(
      _screen(
        client: client,
        args: const CardDetailArgs(cardKey: 'en:swsh4-25', fallback: fallback),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Full Detail Name'), findsWidgets);
    expect(find.text('Fallback Name'), findsNothing);
    expect(find.text('Card detail unavailable'), findsNothing);
  });

  testWidgets('detail API failure with fallback renders fallback card detail', (
    tester,
  ) async {
    final client = _FakeDetailClient(
      (_) async => throw Exception('API error 500'),
    );
    final fallback = SearchResult.fromApiItem(<String, dynamic>{
      'card_key': 'en:swsh4-25',
      'card_id': 'swsh4-25',
      'name': 'Charmeleon',
      'collector_number': '25',
      'language': <String, dynamic>{'code': 'en'},
      'set': <String, dynamic>{'name': 'Vivid Voltage', 'set_id': 'swsh4'},
      'images': <String, dynamic>{
        'local_display_image_url':
            '/api/v1/images/card/en:swsh4-25/content?size=medium',
      },
    }, source: 'primary');

    await tester.pumpWidget(
      _screen(
        client: client,
        args: CardDetailArgs(cardKey: 'en:swsh4-25', fallback: fallback),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Charmeleon'), findsWidgets);
    expect(find.text('Preview from search result'), findsOneWidget);
    expect(find.text('Card detail unavailable'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets(
    'detail API failure without fallback shows friendly unavailable message',
    (tester) async {
      final client = _FakeDetailClient(
        (_) async => throw Exception('API error 500'),
      );

      await tester.pumpWidget(_screen(client: client, args: 'en:swsh4-25'));
      await tester.pumpAndSettle();

      expect(find.text('Card detail unavailable'), findsOneWidget);
      expect(
        find.text('The API could not load this card right now.'),
        findsOneWidget,
      );
      expect(find.text('Card key: en:swsh4-25'), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);
    },
  );
}
