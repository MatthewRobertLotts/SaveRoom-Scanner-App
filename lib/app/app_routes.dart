import 'package:flutter/widgets.dart';

import '../features/cards/card_detail_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/scanner/mock_scan_result_screen.dart';
import '../features/scanner/scanner_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const home = '/';
  static const scanner = '/scanner';
  static const mockScanResult = '/scanner/mock-result';
  static const cardDetail = '/cards/detail';
  static const collection = '/collection';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes({bool? forceFixtureMode}) => {
    home: (_) => HomeScreen(forceFixtureMode: forceFixtureMode),
    scanner: (_) => ScannerScreen(forceFixtureMode: forceFixtureMode),
    mockScanResult: (_) => const MockScanResultScreen(),
    cardDetail: (_) => CardDetailScreen(forceFixtureMode: forceFixtureMode),
    collection: (_) => const CollectionScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
