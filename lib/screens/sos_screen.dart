import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}


class _SosScreenState extends State<SosScreen> {

  //String parentPhone = "201XXXXXXXXX";
  // ⚠️ لازم يكون بصيغة دولية: مصر = 20

  Future<void> sendSOS() async {
    final prefs = await SharedPreferences.getInstance();
    final parentPhone = prefs.getString('parent_phone');

    if (parentPhone == null || parentPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ولي الأمر لازم يسجل رقمه الأول من I am Parent')),
      );
      return;
    }

    // 1) Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2) Get location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    String locationUrl =
        "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

    // 3) Message
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

    // 4) Open WhatsApp
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF0F0),
      appBar: AppBar(
        title: Text("Emergency SOS"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.warning_rounded, color: Colors.red, size: 120),

            SizedBox(height: 20),

            Text(
              "If you are in danger\nPress SOS",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 40),

            GestureDetector(
              onTap: sendSOS,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent, blurRadius: 30)
                  ],
                ),
                child: Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
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
