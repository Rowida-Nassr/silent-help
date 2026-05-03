import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://192.168.1.11:5141/api";

  static Map<String, dynamic> _safeJson(String body) {
    final t = body.trim();
    if (t.isEmpty) return {};
    try {
      final decoded = jsonDecode(t);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"data": decoded};
    } catch (_) {
      // لو رجّع HTML أو أي نص
      return {"raw": t};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final uri = Uri.parse("$baseUrl/Auth/register");

    final res = await http
        .post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullName": fullName,
        "email": email,
        "password": password,
        "role": role,
        "phone": phone,
      }),
    )
        .timeout(const Duration(seconds: 20));

    final json = _safeJson(res.body);

    // ✅ Debug (من غير print)
    debugPrint("REGISTER status=${res.statusCode}");
    debugPrint("REGISTER body=${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    final msg = (json["error"] ?? json["message"] ?? json["raw"] ?? "Register failed").toString();
    throw Exception("$msg (status ${res.statusCode})");
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("$baseUrl/Auth/login");

    final res = await http
        .post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    )
        .timeout(const Duration(seconds: 20));

    final json = _safeJson(res.body);

    debugPrint("LOGIN status=${res.statusCode}");
    debugPrint("LOGIN body=${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    final msg = (json["error"] ?? json["message"] ?? json["raw"] ?? "Login failed").toString();
    throw Exception("$msg (status ${res.statusCode})");
  }
}
