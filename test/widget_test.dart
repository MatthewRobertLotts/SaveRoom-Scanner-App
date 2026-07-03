import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';

void main() {
  testWidgets('home screen shows fixture baseline', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());

    expect(find.text('SaveRoom Scanner'), findsWidgets);
    expect(find.text('v12.2.0'), findsOneWidget);
    expect(find.text('Fixture mode'), findsOneWidget);
  });
}
