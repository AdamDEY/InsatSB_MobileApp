class ApiConfig {
  // TODO: Use environment variable or --dart-define for production
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
}
