import '../config/app_config.dart';
import 'fixture_loader.dart';

class SaveRoomApiClient {
  SaveRoomApiClient({FixtureLoader fixtureLoader = const FixtureLoader()})
      : _fixtureLoader = fixtureLoader;

  final FixtureLoader _fixtureLoader;

  Future<Map<String, dynamic>> getCardDetail(String cardKey) {
    if (AppConfig.fixtureMode) return _fixtureLoader.loadCardDetail();
    throw UnimplementedError('Real API mode is planned after fixture UI hardening.');
  }

  Future<List<Map<String, dynamic>>> searchCards(String query) async {
    if (AppConfig.fixtureMode) return [await _fixtureLoader.loadCardDetail()];
    throw UnimplementedError('Real API search is planned for v12.2 read mode.');
  }

  Future<Map<String, dynamic>> getCurrentUserEntitlements() {
    throw UnimplementedError('App user entitlements are planned for backend v12.3.');
  }
}
