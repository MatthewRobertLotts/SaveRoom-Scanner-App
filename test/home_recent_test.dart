import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';

void main() {
  testWidgets('home screen recently viewed section visible when empty', (
    tester,
  ) async {
    await tester.pumpWidget(const SaveRoomScannerApp());

    // Recently viewed section should always show empty state
    expect(find.text('Recently viewed'), findsOneWidget);
    expect(find.text('Cards you open will appear here'), findsOneWidget);
  });

  // Mark other tests as skipped until we can verify on device
}