import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  group('Language Persistence and AuthProvider Wiring Tests', () {
    test('Initial language defaults to English', () async {
      final auth = AuthProvider();
      await auth.checkAuth();

      expect(auth.language, 'en');
      expect(auth.languageLabel, 'English');
    });

    test('Setting language to Hindi updates state and SharedPreferences', () async {
      final auth = AuthProvider();
      await auth.skipLogin();

      await auth.setLanguage('hi');

      expect(auth.language, 'hi');
      expect(auth.languageLabel, 'हिंदी (Hindi)');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_language'), 'hi');
      expect(auth.user?['language'], 'hi');
    });

    test('Setting language to Marathi updates state and SharedPreferences', () async {
      final auth = AuthProvider();
      await auth.skipLogin();

      await auth.setLanguage('mr');

      expect(auth.language, 'mr');
      expect(auth.languageLabel, 'मराठी (Marathi)');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_language'), 'mr');
      expect(auth.user?['language'], 'mr');
    });

    test('checkAuth restores persisted language across app restarts', () async {
      SharedPreferences.setMockInitialValues({
        'user_language': 'mr',
      });

      final auth = AuthProvider();
      await auth.checkAuth();

      expect(auth.language, 'mr');
      expect(auth.languageLabel, 'मराठी (Marathi)');
    });
  });
}
