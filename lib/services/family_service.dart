import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class FamilyService {
  static const String baseUrl = "http://192.168.1.11:5141/api";

  /// Parent generates invite code
  static Future<String> generateInvite() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http.post(
      Uri.parse("$baseUrl/family/generate-invite"),
      headers: {"Authorization": "Bearer $token"},
    );

    final body = res.body.trim();

    if (res.statusCode == 200) {
      final data = body.isEmpty ? {} : jsonDecode(body);
      return (data["invite_code"] ?? "").toString();
    } else {
      throw Exception("Failed to generate invite (${res.statusCode}): $body");
    }
  }

  /// Child joins family using invite code
  static Future<void> joinFamily({required String inviteCode}) async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http.post(
      Uri.parse("$baseUrl/family/join"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"inviteCode": inviteCode}),
    );

    final body = res.body.trim();
    if (res.statusCode != 200) {
      throw Exception("Join failed (${res.statusCode}): $body");
    }
  }

  static Future<List<dynamic>> getMembers() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http.get(
      Uri.parse("$baseUrl/family/members"),
      headers: {"Authorization": "Bearer $token"},
    );

    final body = res.body.trim();
    if (res.statusCode == 200) {
      final data = body.isEmpty ? {} : jsonDecode(body);
      return (data["members"] ?? []) as List<dynamic>;
    } else {
      throw Exception("Failed to get members (${res.statusCode}): $body");
    }
  }
}
