import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import 'auth_storage.dart';

class AuthService {
  static const String baseUrl = ApiConfig.api;

  static Map<String, dynamic> _safeJson(String body) {
    final t = body.trim();

    if (t.isEmpty) return {};

    try {
      final decoded = jsonDecode(t);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {"data": decoded};
    } catch (_) {
      // لو الـ backend رجّع HTML أو text مش JSON
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

    debugPrint("REGISTER status=${res.statusCode}");
    debugPrint("REGISTER body=${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    final msg = (json["error"] ??
        json["message"] ??
        json["raw"] ??
        "Register failed")
        .toString();

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
      final token = (json["token"] ??
          json["accessToken"] ??
          json["jwt"] ??
          json["data"]?["token"] ??
          json["data"]?["accessToken"])
          ?.toString();

      if (token != null && token.isNotEmpty) {
        await AuthStorage.saveToken(token);

        final savedToken = await AuthStorage.getToken();
        debugPrint("SAVED TOKEN = $savedToken");
      } else {
        debugPrint("LOGIN SUCCESS BUT TOKEN NOT FOUND");
      }

      return json;
    }

    final msg =
    (json["error"] ?? json["message"] ?? json["raw"] ?? "Login failed")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }
}