import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';

void main() {
  testWidgets('scanner screen shows fixture card picker', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());
    await tester.tap(find.text('Start Scanner'));
    await tester.pumpAndSettle();

    expect(
      find.text('Fixture mode — camera/OCR not enabled yet'),
      findsOneWidget,
    );
    expect(find.text('Charizard ex'), findsOneWidget);
    expect(find.text('Miraidon ex'), findsOneWidget);
    expect(find.text('Iono'), findsOneWidget);
  });

  testWidgets('scanner search filters card list', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());
    await tester.tap(find.text('Start Scanner'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'char');
    await tester.pumpAndSettle();

    expect(find.text('Charizard ex'), findsOneWidget);
    expect(find.text('Miraidon ex'), findsNothing);
  });

  testWidgets('tapping fixture card navigates to card detail', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());
    await tester.tap(find.text('Start Scanner'));
    await tester.pumpAndSettle();

    // Tap the first list tile (Charizard ex)
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Should be on card detail page now
    expect(find.text('Card detail'), findsOneWidget);
    // CardImagePanel shows the card name
    expect(find.text('Charizard ex'), findsOneWidget);
  });
}
