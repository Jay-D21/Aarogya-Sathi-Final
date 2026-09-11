/// Centralized API configuration for all backend calls.
///
/// Supports multiple environments:
/// - Emulator: 10.0.2.2:8000 (maps to host localhost)
/// - Physical device: your machine's local IP
/// - Production: Render deployment URL
///
/// Toggle via the `_environment` field below.
class ApiConfig {
  // Change this to switch between environments
  static const _Environment _environment = _Environment.emulator;

  static String get baseUrl {
    switch (_environment) {
      case _Environment.emulator:
        return 'http://10.0.2.2:8000';
      case _Environment.physical:
        // Replace with your machine's actual IP for physical device testing
        return 'http://192.168.1.100:8000';
      case _Environment.production:
        // Your Render deployment URL (set after deploying)
        return 'https://aarogya-sathi-api.onrender.com';
    }
  }

  // Endpoint paths
  static const String chatEndpoint = '/api/chat';
  static const String aqiEndpoint = '/api/aqi';
  static const String healthEndpoint = '/api/health';
}

enum _Environment { emulator, physical, production }
