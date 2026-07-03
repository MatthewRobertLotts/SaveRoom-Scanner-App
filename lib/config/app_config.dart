class AppConfig {
  static const apiBaseline = 'v12.2.0';
  static const apiBaseUrl = String.fromEnvironment(
    'SAVEROOM_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8765',
  );
  static const fixtureMode = bool.fromEnvironment(
    'SAVEROOM_FIXTURE_MODE',
    defaultValue: true,
  );
}
