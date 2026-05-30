import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/alert_service.dart'; // ← غير الـ path حسب مشروعك

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _isLoading = false; // ← عشان نوقف الضغط المزدوج

  Future<void> sendSOS() async {
    if (_isLoading) return; // منع الضغط أكتر من مرة
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final parentPhone = prefs.getString('parent_phone');

      if (parentPhone == null || parentPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ولي الأمر لازم يسجل رقمه الأول من I am Parent'),
          ),
        );
        return;
      }

      // 1) Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2) Get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3) ← الجديد: سجّل الـ alert في الـ backend
      try {
        await AlertService.createAlert(
          triggerType: "button",
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        // لو الـ backend فشل، متوقفش الـ WhatsApp
        debugPrint("Alert service error: $e");
      }

      // 4) بعث WhatsApp زي ما كان
      String locationUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      String message = """
🚨 SOS ALERT 🚨
Silent Help App

A child needs help immediately!
Location:
$locationUrl

Please respond urgently.
""";

      String whatsappUrl =
          "https://wa.me/$parentPhone?text=${Uri.encodeComponent(message)}";

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF0F0),
      appBar: AppBar(
        title: const Text("Emergency SOS"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 120),
            const SizedBox(height: 20),
            const Text(
              "If you are in danger\nPress SOS",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // ← زر SOS مع loading indicator
            GestureDetector(
              onTap: _isLoading ? null : sendSOS,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.red.shade300 : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.redAccent, blurRadius: 30),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Help message will be sent\nwith your live location",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}