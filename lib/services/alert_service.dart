import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AlertService {
  // ✅ خليها نفس الـ base اللي شغال عندك (IP بتاع جهازك + بورت الـ Backend)
  // مثال: http://192.168.1.11:5141
  static const String baseUrl = "http://192.168.1.11:5141";

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

    final uri = Uri.parse("$baseUrl/api/alerts");

    final res = await http.post(
      uri,
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
    );

    final body = res.body.trim();
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Create alert failed (${res.statusCode}): $body");
    }

    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAlerts() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

   final res = await http.get(
  Uri.parse("$baseUrl/api/alerts"),
  headers: {"Authorization": "Bearer $token"},
).timeout(const Duration(seconds: 8));


    final body = res.body.trim();
    if (res.statusCode != 200) {
      throw Exception("Get alerts failed (${res.statusCode}): $body");
    }

    final data = body.isEmpty ? {} : jsonDecode(body);
    final alerts = (data["alerts"] ?? []) as List<dynamic>;
    return alerts;
  }
}
