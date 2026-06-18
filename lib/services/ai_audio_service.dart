import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../ai_api_config.dart';

class AiAudioService {
  static Future<Map<String, dynamic>> analyzeAudio({
    required String audioPath,
    String mode = "background",
  }) async {
    final uri = Uri.parse(AiApiConfig.analyzeAudio);

    final request = http.MultipartRequest("POST", uri);

    request.fields["mode"] = mode;

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        audioPath,
      ),
    );

    debugPrint("AI ANALYZE URL = $uri");
    debugPrint("AI AUDIO PATH = $audioPath");

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 90),
    );

    final responseBody = await streamedResponse.stream.bytesToString();

    debugPrint("AI status=${streamedResponse.statusCode}");
    debugPrint("AI body=$responseBody");

    Map<String, dynamic> data = {};

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        data = {"data": decoded};
      }
    } catch (_) {
      data = {"raw": responseBody};
    }

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return data;
    }

    throw Exception(
      "AI analyze failed (${streamedResponse.statusCode}): $responseBody",
    );
  }
}