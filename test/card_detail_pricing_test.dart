import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';

void main() {
  Future<void> goToCardDetail(WidgetTester tester, {int cardIndex = 0}) async {
    await tester.pumpWidget(const SaveRoomScannerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search cards'));
    await tester.pumpAndSettle();
    final tiles = find.byType(ListTile);
    expect(tiles, findsWidgets);
    await tester.tap(tiles.at(cardIndex));
    await tester.pumpAndSettle();
  }

  group('Card detail pricing formatting', () {
    testWidgets('fallback_price renders formatted GBP not raw map', (
      tester,
    ) async {
      await goToCardDetail(tester);

      await tester.scrollUntilVisible(
        find.text('Pricing / evidence'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Fallback price should show formatted amount (Charizard = 87.90)
      await tester.scrollUntilVisible(
        find.textContaining('£87.90').last,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('£87.90'), findsWidgets);

      // No raw map strings in pricing section
      expect(find.textContaining('{amount'), findsNothing);
      expect(find.textContaining('Instance of'), findsNothing);
    });

    testWidgets('evidence section shows total and source', (tester) async {
      await goToCardDetail(tester);

      await tester.scrollUntilVisible(
        find.text('Evidence'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Source'), findsOneWidget);
    });
  });

  group('All 5 fixture cards render in card detail', () {
    testWidgets('Charizard ex detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 0);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Charizard ex'), findsWidgets);
      expect(find.text('Add to inventory'), findsOneWidget);
      expect(find.text('Add to wishlist'), findsOneWidget);
      expect(find.text('Compare prices'), findsOneWidget);
    });

    testWidgets('Miraidon ex detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 1);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Miraidon ex'), findsWidgets);
    });

    testWidgets('Iono detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 2);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Iono'), findsWidgets);
    });

    testWidgets('Greninja ex detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 3);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Greninja ex'), findsWidgets);
    });

    testWidgets('Giratina V detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 4);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Giratina V'), findsWidgets);
    });
  });

  group('Card detail raw map guard', () {
    testWidgets('no raw map text in card detail', (tester) async {
      await goToCardDetail(tester);
      expect(find.textContaining('{amount'), findsNothing);
      expect(find.textContaining('Instance of'), findsNothing);
      expect(find.textContaining('total_evidence'), findsNothing);
      expect(find.text('Raw fixture debug'), findsNothing);
    });
  });

  group('Scanner picker', () {
    testWidgets('shows all 5 cards', (tester) async {
      await tester.pumpWidget(const SaveRoomScannerApp());
      await tester.tap(find.text('Search cards'));
      await tester.pumpAndSettle();

      for (final name in [
        'Charizard ex',
        'Miraidon ex',
        'Iono',
        'Greninja ex',
        'Giratina V',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('search filters by card key', (tester) async {
      await tester.pumpWidget(const SaveRoomScannerApp());
      await tester.tap(find.text('Search cards'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sv04');
      await tester.pumpAndSettle();

      expect(find.text('Miraidon ex'), findsOneWidget);
      expect(find.text('Charizard ex'), findsNothing);
    });

    testWidgets('empty search state', (tester) async {
      await tester.pumpWidget(const SaveRoomScannerApp());
      await tester.tap(find.text('Search cards'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzznotexist');
      await tester.pumpAndSettle();

      expect(find.text('No fixture cards found'), findsOneWidget);
      expect(find.text('Try another name or card key'), findsOneWidget);
    });

    testWidgets('tapping Miraidon navigates to detail', (tester) async {
      await goToCardDetail(tester, cardIndex: 1);
      expect(find.text('Card detail'), findsOneWidget);
      expect(find.text('Miraidon ex'), findsOneWidget);
    });
  });
}
