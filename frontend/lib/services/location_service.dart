import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _kCachedCity = 'location_cached_city';

  /// Returns the device's current GPS position, or null on any failure.
  static Future<Position?> getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      // Use medium accuracy + 12-second hard timeout so the UI never hangs.
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the city name for the device's current location.
  /// On success, the result is cached in SharedPreferences.
  /// On failure (no GPS, no permission, timeout), returns the previously
  /// cached city name — or null if never detected before.
  static Future<String?> getCityName() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final pos = await getCurrentPosition();
      if (pos == null) {
        return prefs.getString(_kCachedCity);
      }

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 8));

      String? city;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final locality = p.locality;
        final subAdmin = p.subAdministrativeArea;
        final admin = p.administrativeArea;

        debugPrint('[LocationService] Geocode: locality=$locality, '
            'subAdmin=$subAdmin, admin=$admin');

        // Geocoding result hierarchy varies by region. We try multiple fields
        // and pick the most city-like result:
        // - locality is usually the city/town/village name
        // - subAdministrativeArea can be Taluka (e.g. "Shirpur") or Division (e.g. "Nashik Division")
        // - administrativeArea is the state
        // Pick locality unless it looks like a rural sub-village, in which case
        // prefer subAdmin if it doesn't contain "Division" or "District".
        if (locality != null && locality.isNotEmpty) {
          city = locality;
          // If locality is a known rural/small village AND subAdmin is a real city, upgrade
          if (subAdmin != null &&
              subAdmin.isNotEmpty &&
              !subAdmin.toLowerCase().contains('division') &&
              !subAdmin.toLowerCase().contains('district') &&
              subAdmin.length < locality.length) {
            // subAdmin is shorter and cleaner — likely the taluka city name
            city = subAdmin;
          }
        } else if (subAdmin != null &&
            subAdmin.isNotEmpty &&
            !subAdmin.toLowerCase().contains('division') &&
            !subAdmin.toLowerCase().contains('district')) {
          city = subAdmin;
        } else {
          city = admin;
        }
      }

      if (city != null && city.isNotEmpty) {
        await prefs.setString(_kCachedCity, city);
        return city;
      }

      return prefs.getString(_kCachedCity);
    } catch (_) {
      return prefs.getString(_kCachedCity);
    }
  }
}
