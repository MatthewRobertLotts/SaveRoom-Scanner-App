class AppConfig {
  static const appVersion = '0.1.0+1';
  static const apiBaseline = 'v12.2.0';
  static const apiBaseUrl = String.fromEnvironment(
    'SAVEROOM_API_BASE_URL',
    defaultValue: 'http://192.168.178.29:8765',
  );
  static const fixtureMode = bool.fromEnvironment(
    'SAVEROOM_FIXTURE_MODE',
    defaultValue: true,
  );
}
