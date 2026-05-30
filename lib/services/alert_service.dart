import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import 'auth_storage.dart';

class AlertService {
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
      return {"raw": t};
    }
  }

  static Future<Map<String, dynamic>> createAlert({
    required String triggerType, // button / shake / voice
    double? latitude,
    double? longitude,
    String? audioUrl,
  }) async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http
        .post(
      Uri.parse("$baseUrl/Alerts"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "triggerType": triggerType,
        "latitude": latitude,
        "longitude": longitude,
        "audioUrl": audioUrl,
      }),
    )
        .timeout(const Duration(seconds: 20));

    final body = res.body.trim();
    final data = _safeJson(body);

    debugPrint("CREATE ALERT status=${res.statusCode}");
    debugPrint("CREATE ALERT body=$body");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final msg = (data["error"] ??
        data["message"] ??
        data["raw"] ??
        "Create alert failed")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }

  static Future<List<dynamic>> getAlerts() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http
        .get(
      Uri.parse("$baseUrl/Alerts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    )
        .timeout(const Duration(seconds: 20));

    final body = res.body.trim();
    final data = _safeJson(body);

    debugPrint("GET ALERTS status=${res.statusCode}");
    debugPrint("GET ALERTS body=$body");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data["alerts"] is List) {
        return data["alerts"] as List<dynamic>;
      }

      if (data["data"] is List) {
        return data["data"] as List<dynamic>;
      }

      if (data["items"] is List) {
        return data["items"] as List<dynamic>;
      }

      // لو الـ backend رجّع list مباشرة
      final rawData = data["data"];
      if (rawData is List) {
        return rawData;
      }

      return [];
    }

    final msg = (data["error"] ??
        data["message"] ??
        data["raw"] ??
        "Get alerts failed")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }
}