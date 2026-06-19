import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Manages authentication state including login, registration, token
/// refresh, and session persistence. Uses [ApiService] for network calls
/// and [FlutterSecureStorage] indirectly via [ApiService] for token storage.
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String? _error;
  Map<String, dynamic>? _user;
  String _language = 'en';

  bool get isLoading      => _isLoading;
  bool get isLoggedIn     => _isLoggedIn;
  bool get isGuest        => _isGuest;
  String? get error       => _error;
  Map<String, dynamic>? get user => _user;
  String get language     => _language;

  String get languageLabel {
    switch (_language) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'mr':
        return 'मराठी (Marathi)';
      default:
        return 'English';
    }
  }

  /// True when a guest user hasn't completed onboarding yet.
  /// Used by splash to route incomplete profiles back to /onboarding.
  bool get needsOnboarding {
    if (!_isGuest) return false;
    final name = _user?['first_name'] as String?;
    return name == null || name.isEmpty || name == 'Guest' ||
        _user?['height_cm'] == null;
  }

  /// Initiate guest login
  Future<void> skipLogin() async {
    _isGuest = true;
    _isLoggedIn = true;
    
    // Attempt to load existing guest profile & language
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('user_language') ?? 'en';
    final profileStr = prefs.getString('guest_profile');
    if (profileStr != null) {
      _user = jsonDecode(profileStr);
      if (_user?['language'] != null && prefs.getString('user_language') == null) {
        _language = _user!['language'];
        await prefs.setString('user_language', _language);
      }
    } else {
      _user = {
        'id': 'guest',
        'first_name': 'Guest',
        'email': 'guest@aarogyasathi.in',
        'language': _language,
      };
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_language', lang);
    if (_user != null) {
      _user = {..._user!, 'language': lang};
      if (_isGuest) {
        await prefs.setString('guest_profile', jsonEncode(_user));
      } else {
        try {
          await ApiService.put('/auth/me', {'language': lang});
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _user = {...?_user, ...data};
    final prefs = await SharedPreferences.getInstance();
    if (_isGuest) {
      await prefs.setString('guest_profile', jsonEncode(_user));
    } else {
      await prefs.setString('cached_user_profile', jsonEncode(_user));
      try {
        await ApiService.put('/auth/me', data);
      } catch (_) {
        // Silently preserve local update if offline or network unavailable
      }
    }
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('user_language') ?? 'en';

    // Restore guest session if previously active
    if (prefs.getString('guest_profile') != null) {
      await skipLogin();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final resp = await ApiService.get('/auth/me');
        _user = resp['data'] as Map<String, dynamic>?;
        if (_user?['language'] != null && prefs.getString('user_language') == null) {
          _language = _user!['language'];
          await prefs.setString('user_language', _language);
        }
        _isLoggedIn = true;
      } catch (_) {
        // Token expired or backend unreachable — attempt loading cached profile
        final cached = prefs.getString('cached_user_profile');
        if (cached != null) {
          try {
            _user = jsonDecode(cached);
            _isLoggedIn = true;
          } catch (_) {
            await ApiService.clearToken();
            _isLoggedIn = false;
          }
        } else {
          await ApiService.clearToken();
          _isLoggedIn = false;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    String? lastName,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'phone': phone,
        'password': password,
        'first_name': firstName,
      };
      if (lastName != null) data['last_name'] = lastName;
      if (city != null) data['preferred_city'] = city;
      await ApiService.post('/auth/register', data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final data = resp['data'] as Map<String, dynamic>;
      await ApiService.setToken(data['access_token']);
      await ApiService.setRefreshToken(data['refresh_token']);
      _isLoggedIn = true;
      // Fetch profile
      final profile = await ApiService.get('/auth/me');
      _user = profile['data'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    await ApiService.clearToken();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
