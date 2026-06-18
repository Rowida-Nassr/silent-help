import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:hardware_emergency_trigger/hardware_emergency_trigger.dart';

import 'alert_service.dart';
import 'auth_storage.dart';

class HardwareSosService {
  static StreamSubscription<HardwareEmergencyEvent>? _subscription;
  static bool _sending = false;
  static DateTime? _lastSentAt;

  static void start() {
    _subscription ??= HardwareEmergencyTrigger.listen(
      onTriplePress: _sendVolumeSOS,
    );
  }

  static Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static Future<void> _sendVolumeSOS() async {
    if (_sending) return;

    final now = DateTime.now();
    if (_lastSentAt != null &&
        now.difference(_lastSentAt!) < const Duration(seconds: 30)) {
      return;
    }

    _sending = true;

    try {
      final token = await AuthStorage.getToken();
      final role = await AuthStorage.getRole();

      if (token == null || token.isEmpty || role != "child") {
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await AlertService.createAlert(
        triggerType: "button",
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      _lastSentAt = DateTime.now();
    } catch (_) {
      // Silent failure because this runs as emergency background trigger.
    } finally {
      _sending = false;
    }
  }
}