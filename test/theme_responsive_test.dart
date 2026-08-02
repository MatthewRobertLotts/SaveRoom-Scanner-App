import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';
import 'package:saveroom_scanner_app/app/app_routes.dart';

void main() {
  testWidgets('card detail survives 200 percent text scaling', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      const SaveRoomScannerApp(initialRoute: AppRoutes.cardDetail),
    );
    await tester.pumpAndSettle();

    expect(find.text('Card detail'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
