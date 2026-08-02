import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';
import 'package:saveroom_scanner_app/app/app_routes.dart';

void main() {
  testWidgets('scanner screen shows fixture card picker', (tester) async {
    await tester.pumpWidget(
      const SaveRoomScannerApp(initialRoute: AppRoutes.search),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search cards'), findsOneWidget);
    expect(find.text('Charizard ex'), findsOneWidget);
    expect(find.text('Miraidon ex'), findsOneWidget);
    expect(find.text('Iono'), findsOneWidget);
  });

  testWidgets('scanner search filters card list', (tester) async {
    await tester.pumpWidget(
      const SaveRoomScannerApp(initialRoute: AppRoutes.search),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'char');
    await tester.pumpAndSettle();

    expect(find.text('Charizard ex'), findsOneWidget);
    expect(find.text('Miraidon ex'), findsNothing);
  });

  testWidgets('camera scanner opens scanner landing before search', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SaveRoomScannerApp(initialRoute: AppRoutes.scanner),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scan card'), findsOneWidget);
    expect(find.text('Keep the full card inside the frame'), findsOneWidget);
    expect(find.text('LIGHTING'), findsOneWidget);
    expect(find.text('Good  •  Hold steady'), findsOneWidget);
  });

  testWidgets('tapping fixture card navigates to card detail', (tester) async {
    await tester.pumpWidget(
      const SaveRoomScannerApp(initialRoute: AppRoutes.search),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Charizard ex').first);
    await tester.pumpAndSettle();

    expect(find.text('Card detail'), findsOneWidget);
    expect(find.text('Charizard ex'), findsOneWidget);
  });
}
