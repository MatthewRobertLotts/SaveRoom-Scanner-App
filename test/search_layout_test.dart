import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:saveroom_scanner_app/features/scanner/scanner_screen.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';
import 'package:saveroom_scanner_app/widgets/card_thumbnail.dart';

void main() {
  testWidgets(
    'search result row with image does not overflow on phone viewport',
    (tester) async {
      // Narrow phone size
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      addTearDown(tester.view.reset);

      final client = SaveRoomApiClient(
        forceFixtureMode: false,
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'card_key': 'en:test-1',
                  'name': 'Pikachu',
                  'language': {'code': 'en'},
                  'display_text': 'Base Set / base / 25',
                  'image_url_candidates': [
                    'https://assets.tcgdex.net/en/base/base25/25.png',
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerScreen(client: client, forceLiveMode: true),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'pika');
      await tester.pump(const Duration(milliseconds: 260));
      await tester.pumpAndSettle();

      // No Flutter overflow exception
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search result row without image does not overflow on phone viewport',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      addTearDown(tester.view.reset);

      final client = SaveRoomApiClient(
        forceFixtureMode: false,
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'card_key': 'en:test-1',
                  'name': 'Test Card Without Image',
                  'language': {'code': 'en'},
                  'display_text': 'Unknown Set / unknown / 999',
                },
              ],
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerScreen(client: client, forceLiveMode: true),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 260));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('long card name does not overflow badly', (tester) async {
    tester.view.physicalSize = const Size(360 * 2, 640 * 2);
    addTearDown(tester.view.reset);

    final client = SaveRoomApiClient(
      forceFixtureMode: false,
      httpClient: MockClient((req) async {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'card_key': 'en:test-long',
                'name':
                    'Very Long Card Name That Should Be Ellipsized Properly',
                'language': {'code': 'en'},
                'display_text':
                    'Some Extremely Long Set Name That Also Needs Truncation / xy99 / 12345',
              },
            ],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerScreen(client: client, forceLiveMode: true),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'very');
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpAndSettle();

    // No overflow
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed thumbnail shows placeholder without setState during build error',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      addTearDown(tester.view.reset);

      final client = SaveRoomApiClient(
        forceFixtureMode: false,
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'card_key': 'en:test-fail',
                  'name': 'Test Card Bad Image',
                  'language': {'code': 'en'},
                  'display_text': 'Test Set / test / 1',
                  'image_url_candidates': [
                    'https://broken.url/that/will/fail.png',
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerScreen(client: client, forceLiveMode: true),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 260));
      await tester.pumpAndSettle();

      // No setState during build error should occur
      expect(tester.takeException(), isNull);
      // Should show placeholder icon instead of error text
      expect(find.byIcon(LucideIcons.image), findsWidgets);
    },
  );

  testWidgets('CardThumbnail exhausts failed candidates to clean placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CardThumbnail(
            imageUrls: [
              'http://127.0.0.1:1/missing-a.png',
              'http://127.0.0.1:1/missing-b.png',
            ],
            cardName: 'All Failed Test',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.byIcon(LucideIcons.image), findsWidgets);
    expect(find.textContaining('setState'), findsNothing);
    expect(find.textContaining('markNeedsBuild'), findsNothing);
  });

  testWidgets('CardThumbnail contains whole card image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CardThumbnail(
            imageUrls: ['https://example.com/card.png'],
            cardName: 'Whole Card Test',
          ),
        ),
      ),
    );

    expect(
      tester.widget<ExtendedImage>(find.byType(ExtendedImage)).fit,
      BoxFit.contain,
    );
  });
}
