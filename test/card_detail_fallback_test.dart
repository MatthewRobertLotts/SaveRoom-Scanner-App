import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/features/cards/card_detail_screen.dart';
import 'package:saveroom_scanner_app/services/fixture_loader.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';
import 'package:saveroom_scanner_app/widgets/card_image_panel.dart';

class _FakeDetailClient extends SaveRoomApiClient {
  _FakeDetailClient(this.loader, {this.searcher})
    : super(fixtureLoader: const FixtureLoader());

  final Future<Map<String, dynamic>> Function(String cardKey) loader;
  final Future<List<SearchResult>> Function(String query)? searcher;

  @override
  Future<Map<String, dynamic>> getCardDetail(String cardKey) => loader(cardKey);

  @override
  Future<List<SearchResult>> searchCards(String query) async =>
      searcher == null ? super.searchCards(query) : searcher!(query);
}

Map<String, dynamic> _detail(String name, String key) => <String, dynamic>{
  'data': <String, dynamic>{
    'card': <String, dynamic>{
      'card_key': key,
      'name': name,
      'language_code': 'en',
      'collector_number': key.split('-').last,
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

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Full Detail Name'), findsWidgets);
    expect(find.text('Fallback Name'), findsNothing);
    expect(find.text('Card detail unavailable'), findsNothing);
  });

  testWidgets('swiping card image opens same-name variant detail', (
    tester,
  ) async {
    final client = _FakeDetailClient(
      (key) async => key == 'en:swsh4-26'
          ? _detail('Pikachu', 'en:swsh4-26')
          : _detail('Pikachu', 'en:swsh4-25'),
      searcher: (_) async => const [
        SearchResult(cardKey: 'en:swsh4-25', name: 'Pikachu', setText: '25'),
        SearchResult(cardKey: 'en:swsh4-26', name: 'Pikachu', setText: '26'),
      ],
    );

    await tester.pumpWidget(_screen(client: client, args: 'en:swsh4-25'));
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(CardImagePanel).first,
      const Offset(-320, 0),
      900,
    );
    await tester.pumpAndSettle();

    expect(find.text('26'), findsWidgets);
  });

  testWidgets('live v12 detail shape renders number and pricing source', (
    tester,
  ) async {
    final client = _FakeDetailClient(
      (_) async => <String, dynamic>{
        'data': <String, dynamic>{
          'card': <String, dynamic>{
            'card_key': 'en:sv03-223',
            'name': 'Charizard ex',
            'language_code': 'en',
            'number': '223',
          },
          'set': <String, dynamic>{'name': 'Obsidian Flames'},
          'images': <String, dynamic>{},
          'pricing': <String, dynamic>{
            'primary_price': null,
            'fallback_price': <String, dynamic>{
              'amount': 87.9,
              'currency': 'GBP',
              'source': 'rapidapi_ebay_average_selling_price',
            },
            'source_breakdown': <Map<String, dynamic>>[
              <String, dynamic>{
                'source': 'rapidapi_ebay_average_selling_price',
              },
            ],
            'evidence_summary': <String, dynamic>{
              'total_evidence': 58,
              'uk_evidence': 0,
            },
          },
          'provider_status': <String, dynamic>{},
        },
      },
    );

    await tester.pumpWidget(_screen(client: client, args: 'en:sv03-223'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('223'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('RapidAPI eBay average selling price'), findsWidgets);
  });

  testWidgets('empty evidence summary renders one friendly fallback', (
    tester,
  ) async {
    final client = _FakeDetailClient(
      (_) async => <String, dynamic>{
        'data': <String, dynamic>{
          'card': <String, dynamic>{
            'card_key': 'en:ex2-72',
            'name': 'Pikachu',
            'language_code': 'en',
            'collector_number': '72',
          },
          'set': <String, dynamic>{'name': 'Sandstorm'},
          'images': <String, dynamic>{},
          'pricing': <String, dynamic>{
            'fallback_price': <String, dynamic>{
              'amount': null,
              'source': 'rapidapi_ebay_average_selling_price',
            },
            'evidence_summary': <String, dynamic>{
              'total_evidence': 0,
              'uk_evidence': 0,
            },
          },
          'provider_status': <String, dynamic>{
            'uk_ebay_sold': <String, dynamic>{},
          },
        },
      },
    );

    await tester.pumpWidget(_screen(client: client, args: 'en:ex2-72'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(
      find.text('No pricing or evidence is available for this card yet.'),
      findsOneWidget,
    );
    expect(find.text('Source'), findsNothing);
    expect(find.text('Data sources'), findsNothing);
    expect(find.text('Total'), findsNothing);
    expect(find.text('None'), findsNothing);
    expect(find.text('UK evidence'), findsNothing);
    expect(find.text('None yet'), findsNothing);
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
