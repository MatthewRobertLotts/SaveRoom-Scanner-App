import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/widgets/card_image_panel.dart';

class _TestData {
  static Map<String, dynamic> cardDetailData() => <String, dynamic>{
    'card': <String, dynamic>{
      'name': 'Pikachu',
      'card_key': 'en:sv01-001',
      'language_code': 'en',
      'rarity': 'Rare',
      'collector_number': '001',
    },
    'set': <String, dynamic>{'name': 'Test Set', 'set_code': 'sv01'},
    'images': <String, dynamic>{
      'has_local_image': false,
      'display_image_url': null,
    },
  };

  static Map<String, dynamic> dataWithNullRarity() => <String, dynamic>{
    'card': <String, dynamic>{
      'name': 'Test Card',
      'language_code': 'en',
      'rarity': null,
    },
    'set': <String, dynamic>{'name': 'Test Set'},
    'images': <String, dynamic>{'has_local_image': true},
  };
}

void main() {
  group('CardImagePanel', () {
    testWidgets('renders card name and image placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImagePanel.fromData(_TestData.cardDetailData()),
          ),
        ),
      );

      expect(find.text('Pikachu'), findsWidgets);
      expect(find.text('Image pending'), findsOneWidget);
    });

    testWidgets('shows set text when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImagePanel.fromData(_TestData.cardDetailData()),
          ),
        ),
      );

      // "Test Set / sv01 / 001" is the joinPresent setText
      expect(find.textContaining('Test Set'), findsOneWidget);
      expect(find.textContaining('sv01'), findsOneWidget);
    });

    testWidgets('shows language and rarity metadata', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImagePanel.fromData(_TestData.cardDetailData()),
          ),
        ),
      );

      expect(find.text('en'), findsOneWidget);
      expect(find.text('Rare'), findsOneWidget);
    });

    testWidgets('handles null rarity gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardImagePanel.fromData(_TestData.dataWithNullRarity()),
          ),
        ),
      );

      // Card name still shows
      expect(find.text('Test Card'), findsWidgets);
      // Rarity icon should not be rendered for null
      // Just verify no crash and "Image pending" shows for has_local_image
      expect(find.text('Image pending'), findsOneWidget);
    });

    testWidgets(
      'candidate URL shows loading state instead of immediate Image pending',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardImagePanel(
                cardName: 'Pikachu',
                imageUrls: ['http://example.invalid/pikachu.png'],
              ),
            ),
          ),
        );

        expect(find.text('Loading image'), findsOneWidget);
        expect(find.text('Image pending'), findsNothing);
      },
    );

    testWidgets('failed candidate eventually falls back to Image pending', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardImagePanel(
              cardName: 'Pikachu',
              imageUrls: ['http://example.invalid/pikachu.png'],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('Image pending'), findsOneWidget);
    });
  });
}
