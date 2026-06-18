import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ai_audio_service.dart';
import 'alert_service.dart';

class VoiceMonitorService {
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  static bool _isRecorderOpened = false;
  static bool _isRecording = false;

  static Future<void> listenOnceForFiveSeconds() async {
    try {
      final micStatus = await Permission.microphone.request();

      if (!micStatus.isGranted) {
        debugPrint("MICROPHONE PERMISSION DENIED");
        return;
      }

      if (!_isRecorderOpened) {
        await _recorder.openRecorder();
        _isRecorderOpened = true;
      }

      final dir = await getTemporaryDirectory();

      final audioPath =
          "${dir.path}/silent_help_${DateTime.now().millisecondsSinceEpoch}.wav";

      debugPrint("VOICE ONE-TIME RECORDING STARTED: $audioPath");

      _isRecording = true;

      await _recorder.startRecorder(
        toFile: audioPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );

      await Future.delayed(const Duration(seconds: 3));

      final recordedPath = await _recorder.stopRecorder();
      _isRecording = false;

      if (recordedPath == null || recordedPath.isEmpty) {
        debugPrint("VOICE RECORDING FAILED");
        return;
      }

      debugPrint("VOICE ONE-TIME RECORDING FINISHED: $recordedPath");

      final aiResult = await AiAudioService.analyzeAudio(
        audioPath: recordedPath,
        mode: "background",
      );

      debugPrint("VOICE AI RESULT: $aiResult");

      final shouldAlert = aiResult["alert"] == true;

      if (!shouldAlert) {
        debugPrint("NO DANGER WORD DETECTED IN 5 SECONDS");
        return;
      }

      debugPrint("DANGER WORD DETECTED. SENDING SOS ALERT...");

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await AlertService.createAlert(
        triggerType: "voice",
        latitude: position.latitude,
        longitude: position.longitude,
        audioUrl: null,
      );

      debugPrint("VOICE SOS ALERT SENT SUCCESSFULLY");
    } catch (e) {
      debugPrint("VOICE ONE-TIME ERROR: $e");
    }
  }

  static Future<void> stopIfRecording() async {
    if (_isRecording) {
      try {
        await _recorder.stopRecorder();
      } catch (_) {}

      _isRecording = false;
    }

    if (_isRecorderOpened) {
      try {
        await _recorder.closeRecorder();
      } catch (_) {}

      _isRecorderOpened = false;
    }

    debugPrint("VOICE RECORDER CLOSED");
  }
}