/// Centralized API configuration for Aarogya Sathi.
///
/// Supports three environments:
/// - production: Deployed FastAPI backend on Render
/// - emulator: Android emulator (10.0.2.2:8000 maps to host localhost)
/// - physical: Local network IP address for physical device debugging
class ApiConfig {
  // Switch to _Environment.production before committing / deploying
  static const _Environment _environment = _Environment.emulator;

  static String get baseUrl {
    switch (_environment) {
      case _Environment.production:
        return 'https://aarogya-sathi-final.onrender.com';
      case _Environment.emulator:
        return 'http://10.0.2.2:8000';
      case _Environment.physical:
        return 'http://10.219.186.110:8000';
    }
  }

  static String get healthCheckUrl => '$baseUrl/api/health';
  static String get chatEndpoint => '$baseUrl/api/chat';
  static String get aqiEndpoint => '$baseUrl/api/aqi';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

enum _Environment { emulator, physical, production }
