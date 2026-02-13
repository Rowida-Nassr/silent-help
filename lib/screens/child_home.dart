import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_background.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  Future<void> _sendSOS(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentPhone = prefs.getString('parent_phone');

      if (parentPhone == null || parentPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent must register phone number first (I am Parent).')),
        );
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are OFF. Please turn on GPS.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied forever. Enable it from Settings.')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final locationUrl = "https://www.google.com/maps?q=${pos.latitude},${pos.longitude}";

      await prefs.setString('last_sos_time', DateTime.now().toString());
      await prefs.setString('last_sos_location_url', locationUrl);
      await prefs.setString('last_sos_message', 'A child needs help immediately!');

      final message = Uri.encodeComponent(
        "🚨 SOS ALERT 🚨\nSilent Help App\n\nA child needs help immediately!\nLocation:\n$locationUrl\n\nPlease respond urgently.",
      );

      final waUrl = Uri.parse("https://wa.me/$parentPhone?text=$message");

      if (!await canLaunchUrl(waUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Please install WhatsApp.')),
        );
        return;
      }

      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SOS failed: $e")),
      );
    }
  }

  Future<void> _confirmBack(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Go back?"),
        content: const Text("Do you want to return to Role Select?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (ok == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 14),

                // 🔝 Top bar
                Row(
                  children: [
                    _BouncyIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => _confirmBack(context),
                    ),
                    const SizedBox(width: 10),

                    const Icon(Icons.shield_rounded, color: Colors.white, size: 34),
                    const SizedBox(width: 10),
                    const Text(
                      "Silent Help",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Child Mode 👶",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Friendly message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Text(
                    "If you feel unsafe, press the big SOS button.\nWe are here with you 💙",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // 🧸 Big SOS Button (sends SOS directly)
                _BouncyCircleButton(
                  onTap: () => _sendSOS(context),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xffFF416C), Color(0xffFF4B2B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.35),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_rounded, color: Colors.white, size: 60),
                        SizedBox(height: 10),
                        Text(
                          "SOS",
                          style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap here",
                          style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Small actions
                Row(
                  children: [
                    Expanded(
                      child: _smallCard(
                        icon: Icons.check_circle,
                        title: "I'm OK",
                        color: const Color(0xff2ECC71),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Great! Stay safe 💙")),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _smallCard(
                        icon: Icons.lightbulb,
                        title: "Safety Tips",
                        color: const Color(0xffF39C12),
                        onTap: () => _showTips(context),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text(
                    "In an emergency, press SOS quickly 🚨",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _smallCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }

  static void _showTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Safety Tips 💡", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListTile(leading: Icon(Icons.star), title: Text("Go to a safe place if you can.")),
              ListTile(leading: Icon(Icons.star), title: Text("Stay near trusted adults.")),
              ListTile(leading: Icon(Icons.star), title: Text("Press SOS if you feel unsafe.")),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Bouncy circle button for SOS
class _BouncyCircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyCircleButton({required this.child, required this.onTap});

  @override
  State<_BouncyCircleButton> createState() => _BouncyCircleButtonState();
}

class _BouncyCircleButtonState extends State<_BouncyCircleButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

// ✅ Cute back button with bounce + circle background
class _BouncyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BouncyIconButton({required this.icon, required this.onTap});

  @override
  State<_BouncyIconButton> createState() => _BouncyIconButtonState();
}

class _BouncyIconButtonState extends State<_BouncyIconButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
