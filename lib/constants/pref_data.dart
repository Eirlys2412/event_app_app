import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefData {
  static const String _prefName = "com.example.shopping";
  static const String _introAvailable = "${_prefName}isIntroAvailable";
  static const String _isLoggedIn = "${_prefName}isLoggedIn";
  static const String _token = "${_prefName}token";
  static const String _role = "${_prefName}role";
  static const String _userId = "${_prefName}userId";
  static const String _userData = "${_prefName}userData";

  /// SharedPreferences instance
  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  // Intro screen
  static Future<bool> isIntroAvailable() async {
    final prefs = await _prefs();
    return prefs.getBool(_introAvailable) ?? true;
  }

  static Future<void> setIntroAvailable(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_introAvailable, value);
  }

  // Login state
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_isLoggedIn, value);
  }

  // Token
  static Future<void> setToken(String value) async {
    final prefs = await _prefs();
    await prefs.setString(_token, value);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs();
    return prefs.getString(_token);
  }

  // User ID
  static Future<void> setUserId(int id) async {
    final prefs = await _prefs();
    await prefs.setInt(_userId, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await _prefs();
    return prefs.getInt(_userId);
  }

  // Role
  static Future<void> setRole(String role) async {
    final prefs = await _prefs();
    await prefs.setString(_role, role);
  }

  static Future<String?> getRole() async {
    final prefs = await _prefs();
    return prefs.getString(_role);
  }

  static Future<bool> isEventManager() async {
    final role = await getRole();
    return role == 'eventmanager';
  }

  static Future<bool> isEventMember() async {
    final role = await getRole();
    return role == 'eventmember';
  }

  // Save login state
  static Future<void> saveLoginState(String token, Map<String, dynamic> userData) async {
    final prefs = await _prefs();
    await prefs.setBool(_isLoggedIn, true);
    await prefs.setString(_token, token);
    await prefs.setInt(_userId, userData['id']);
    await prefs.setString(_role, userData['role'] ?? '');
    await prefs.setString(_userData, jsonEncode(userData));
  }

  // Clear login data
  static Future<void> clearUserData() async {
    final prefs = await _prefs();
    await prefs.remove(_token);
    await prefs.remove(_userId);
    await prefs.remove(_role);
    await prefs.remove(_userData);
    await prefs.setBool(_isLoggedIn, false);
  }

  // Logout
  static Future<void> logout() async {
    await clearUserData();
  }

  // Get full user data (optional)
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs();
    final jsonString = prefs.getString(_userData);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }
}
