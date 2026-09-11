import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/data/user_profile_model.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';

  Future<void> saveProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJson());
  }

  Future<UserProfileModel?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      return UserProfileModel.fromJson(profileJson);
    }
    return null;
  }

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
