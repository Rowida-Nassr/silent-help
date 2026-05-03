import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _kToken = "token";
  static const _kRole = "role";
  static const _kEmail = "email";
  static const _kName = "name";
  static const _kUserId = "userId";

  static Future<void> saveAuth({
    required String token,
    required String role,
    required String email,
    required String name,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kRole, role);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kName, name);
    await prefs.setString(_kUserId, userId);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRole);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kName);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kRole);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    await prefs.remove(_kUserId);
  }
}
