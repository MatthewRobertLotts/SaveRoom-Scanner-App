import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saveroom_scanner_app/features/scanner/scanner_screen.dart';
import 'package:saveroom_scanner_app/services/saveroom_api_client.dart';

void main() {
  Widget harness(SaveRoomApiClient client) => MaterialApp(
    home: Scaffold(body: ScannerScreen(client: client, forceLiveMode: true)),
  );

  testWidgets('API connection failure does not look like no cards found', (
    tester,
  ) async {
    final client = SaveRoomApiClient(
      forceFixtureMode: false,
      httpClient: MockClient((_) async => http.Response('unavailable', 503)),
    );

    await tester.pumpWidget(harness(client));
    await tester.enterText(find.byType(TextField), 'charizard');
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpAndSettle();

    expect(
      find.text('Search failed. Check the API connection.'),
      findsOneWidget,
    );
    expect(find.text('No cards found'), findsNothing);
  });

  testWidgets('No cards found appears only after successful empty response', (
    tester,
  ) async {
    final client = SaveRoomApiClient(
      forceFixtureMode: false,
      httpClient: MockClient((req) async {
        return http.Response(jsonEncode({'data': []}), 200);
      }),
    );

    await tester.pumpWidget(harness(client));
    await tester.enterText(find.byType(TextField), 'nonsense');
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpAndSettle();

    expect(find.text('No cards found'), findsOneWidget);
    expect(find.text('Search failed. Check the API connection.'), findsNothing);
  });

  testWidgets('preserves old results while newer search is loading', (
    tester,
  ) async {
    var charizardReturned = false;
    final client = SaveRoomApiClient(
      forceFixtureMode: false,
      httpClient: MockClient((req) async {
        final query = req.url.queryParameters['q'] ?? '';
        if (query == 'charizard') {
          charizardReturned = true;
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'card_key': 'en:charizard-1',
                  'name': 'Charizard',
                  'language': {'code': 'en'},
                },
              ],
            }),
            200,
          );
        }
        if (query == 'pikachu' && charizardReturned) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          return http.Response(jsonEncode({'data': []}), 200);
        }
        return http.Response(jsonEncode({'data': []}), 200);
      }),
    );

    await tester.pumpWidget(harness(client));
    await tester.enterText(find.byType(TextField), 'charizard');
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpAndSettle();
    expect(find.text('Charizard'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pikachu');
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('Charizard'), findsOneWidget);
    expect(find.text('Updating results…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
