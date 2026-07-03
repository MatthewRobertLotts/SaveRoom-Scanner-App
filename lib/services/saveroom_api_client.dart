import '../config/app_config.dart';
import 'fixture_loader.dart';

class SaveRoomApiClient {
  SaveRoomApiClient({FixtureLoader fixtureLoader = const FixtureLoader()})
    : _fixtureLoader = fixtureLoader;

  final FixtureLoader _fixtureLoader;

  Future<Map<String, dynamic>> getCardDetail(String cardKey) {
    if (AppConfig.fixtureMode) return _fixtureLoader.loadCardDetail();
    throw UnimplementedError(
      'Real API mode is intentionally off until the v12.2 read-mode milestone.',
    );
  }

  Future<List<Map<String, dynamic>>> searchCards(String query) async {
    if (AppConfig.fixtureMode) return [await _fixtureLoader.loadCardDetail()];
    throw UnimplementedError(
      'Real API search is planned, but never called by default.',
    );
  }

  Future<Map<String, dynamic>> getCurrentUserEntitlements() {
    throw UnimplementedError('App user entitlements are backend v12.3 work.');
  }
}
