import 'package:flutter_test/flutter_test.dart';
import 'package:saveroom_scanner_app/app/app.dart';
import 'package:saveroom_scanner_app/config/app_config.dart';

void main() {
  testWidgets('home screen shows visual shell basics', (tester) async {
    await tester.pumpWidget(const SaveRoomScannerApp());

    expect(find.text('SaveRoom Scanner'), findsWidgets);
    expect(find.text('Fixture mode'), findsOneWidget);
    expect(find.text('Search cards'), findsOneWidget);
  });

  group('AppConfig defaults', () {
    test('fixtureMode defaults to true', () {
      expect(AppConfig.fixtureMode, true);
    });

    test('apiBaseUrl defaults to http://127.0.0.1:8765', () {
      expect(AppConfig.apiBaseUrl, 'http://127.0.0.1:8765');
    });
  });
}
