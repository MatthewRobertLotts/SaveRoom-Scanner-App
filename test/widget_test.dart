import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';

void main() {
  testWidgets('home screen shows visual shell basics', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());

    expect(find.text('SaveRoom Scanner'), findsWidgets);
    expect(find.text('Fixture result'), findsOneWidget);
    expect(find.text('API baseline: v12.2.0'), findsOneWidget);
    expect(find.text('Start Scanner'), findsOneWidget);
    expect(find.text('View Mock Card'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('card detail renders fixture data', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());
    await tester.tap(find.text('View Mock Card'));
    await tester.pumpAndSettle();

    expect(find.text('Charizard ex'), findsOneWidget);
    expect(find.text('Obsidian Flames / sv03 / 223'), findsOneWidget);
    expect(find.text('Fixture result'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Pricing / evidence'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Inventory / commercial'), 300);
    expect(find.text('Inventory / commercial'), findsOneWidget);
  });
}
