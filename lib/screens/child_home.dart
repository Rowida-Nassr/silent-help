import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'app_background.dart';
import '../services/voice_monitor_service.dart';
import '../services/alert_service.dart';
import 'safety_learning_screen.dart';
import 'role_select.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      VoiceMonitorService.listenOnceForFiveSeconds();
    });
  }

  @override
  void dispose() {
    // VoiceMonitorService.stopIfRecording();
    super.dispose();
  }

  Future<void> _sendSOS(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!context.mounted) return;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!context.mounted) return;

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are OFF. Please turn on GPS.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (!context.mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!context.mounted) return;
      }

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied forever. Enable it from Settings.',
            ),
          ),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!context.mounted) return;

      await AlertService.createAlert(
        triggerType: "button",
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (!context.mounted) return;

      final locationUrl =
          "https://www.google.com/maps?q=${pos.latitude},${pos.longitude}";

      await prefs.setString('last_sos_time', DateTime.now().toString());
      await prefs.setString('last_sos_location_url', locationUrl);
      await prefs.setString(
        'last_sos_message',
        'A child needs help immediately!',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert sent successfully.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SOS failed: $e")),
      );
    }
  }

  Future<void> _confirmBack(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Go back?"),
        content: const Text("Do you want to return to Role Select?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleSelectScreen(),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmBack(context);
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sosSize =
                (constraints.maxHeight * 0.30).clamp(185.0, 250.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _BouncyIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => _confirmBack(context),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            const Flexible(
                              child: Text(
                                "Silent Help",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                "Child Mode 👶",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Text(
                            "If you feel unsafe, say the danger word in the first 5 seconds.\n"
                                "If it is not detected, press the big SOS button 💙",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mic_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Voice check runs once for 5 seconds",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _BouncyCircleButton(
                          onTap: () => _sendSOS(context),
                          child: Container(
                            width: sosSize,
                            height: sosSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffFF416C),
                                  Color(0xffFF4B2B),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.35),
                                  blurRadius: 34,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: sosSize * 0.24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "SOS",
                                  style: TextStyle(
                                    fontSize: sosSize * 0.22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Tap here",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _smallCard(
                                icon: Icons.lightbulb,
                                title: "Safety Tips",
                                color: const Color(0xffF39C12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const SafetyLearningScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text(
                            "In an emergency, say the danger word or press SOS 🚨",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncyCircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyCircleButton({
    required this.child,
    required this.onTap,
  });

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

class _BouncyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BouncyIconButton({
    required this.icon,
    required this.onTap,
  });

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
            color: Colors.black.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}