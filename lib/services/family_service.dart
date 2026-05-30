import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import 'auth_storage.dart';

class FamilyService {
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

  /// Parent generates invite code
  static Future<String> generateInvite() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http
        .post(
      Uri.parse("$baseUrl/Family/generate-invite"),
      headers: {
        "Authorization": "Bearer $token",
      },
    )
        .timeout(const Duration(seconds: 20));

    final body = res.body.trim();
    final data = _safeJson(body);

    debugPrint("GENERATE INVITE status=${res.statusCode}");
    debugPrint("GENERATE INVITE body=$body");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final inviteCode = (data["inviteCode"] ??
          data["invite_code"] ??
          data["code"] ??
          data["data"]?["inviteCode"] ??
          data["data"]?["invite_code"] ??
          data["data"]?["code"])
          ?.toString();

      if (inviteCode == null || inviteCode.isEmpty) {
        throw Exception("Invite generated but invite code was not found in response.");
      }

      return inviteCode;
    }

    final msg = (data["error"] ??
        data["message"] ??
        data["raw"] ??
        "Failed to generate invite")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }

  /// Child joins family using invite code
  static Future<void> joinFamily({required String inviteCode}) async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http
        .post(
      Uri.parse("$baseUrl/Family/join"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "inviteCode": inviteCode,
      }),
    )
        .timeout(const Duration(seconds: 20));

    final body = res.body.trim();
    final data = _safeJson(body);

    debugPrint("JOIN FAMILY status=${res.statusCode}");
    debugPrint("JOIN FAMILY body=$body");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }

    final msg =
    (data["error"] ?? data["message"] ?? data["raw"] ?? "Join failed")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }

  static Future<List<dynamic>> getMembers() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Not logged in (token missing).");
    }

    final res = await http
        .get(
      Uri.parse("$baseUrl/Family/members"),
      headers: {
        "Authorization": "Bearer $token",
      },
    )
        .timeout(const Duration(seconds: 20));

    final body = res.body.trim();
    final data = _safeJson(body);

    debugPrint("GET MEMBERS status=${res.statusCode}");
    debugPrint("GET MEMBERS body=$body");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data["members"] is List) {
        return data["members"] as List<dynamic>;
      }

      if (data["data"] is List) {
        return data["data"] as List<dynamic>;
      }

      if (data["items"] is List) {
        return data["items"] as List<dynamic>;
      }

      return [];
    }

    final msg = (data["error"] ??
        data["message"] ??
        data["raw"] ??
        "Failed to get members")
        .toString();

    throw Exception("$msg (status ${res.statusCode})");
  }
}