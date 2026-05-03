import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_background.dart';
import '../services/auth_storage.dart';
import '../services/alert_service.dart';
import '../services/family_service.dart';
import 'parent_login.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _loading = true;

  // UI (local temporary)
  String childName = "-";
  String childGender = "-";
  String childDob = "-";

  // Parent info (mixed)
  String parentName = "-"; // from AuthStorage
  String parentRole = "-"; // local temporary
  String parentDob = "-"; // local temporary

  String phone1 = "-"; // local
  String phone2 = "-"; // local
  String email = "-"; // from AuthStorage

  // Last SOS (prefer backend alerts)
  String lastSosTime = "-";
  String lastSosLocationUrl = "";
  String lastSosMessage = "-";
  String lastSosTrigger = "-";

  // Alerts list (from backend)
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _goLogin() async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
          (_) => false,
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // ✅ لو مفيش token أو role مش parent -> login
    final token = await AuthStorage.getToken();
    final role = await AuthStorage.getRole();
    if (token == null || token.isEmpty || role != "parent") {
      await _goLogin();
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // ✅ Local temporary
    childName = prefs.getString('child_name') ?? "-";
    childGender = prefs.getString('child_gender') ?? "-";
    childDob = prefs.getString('child_dob') ?? "-";

    phone1 = prefs.getString('parent_phone') ?? "-";
    phone2 = prefs.getString('parent_phone_2') ?? "-";
    parentDob = prefs.getString('parent_dob') ?? "-";
    parentRole = prefs.getString('parent_role') ?? "-";

    // ✅ From backend login storage
    // لازم تكوني عاملة getEmail/getName في AuthStorage
    email = (await AuthStorage.getEmail()) ?? "-";
    parentName = (await AuthStorage.getName()) ?? "-";

    // ✅ Local SOS fallback
    final localSosTime = prefs.getString('last_sos_time') ?? "-";
    final localSosLocation = prefs.getString('last_sos_location_url') ?? "";
    final localSosMessage = prefs.getString('last_sos_message') ?? "-";

    // ✅ Get alerts from backend
    try {
      final alertsRaw = await AlertService.getAlerts();
      _alerts = alertsRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      if (_alerts.isNotEmpty) {
        final a = _alerts.first;

        final lat = a["latitude"];
        final lng = a["longitude"];
        final createdAt = (a["createdAt"] ?? "").toString();
        final trigger = (a["triggerType"] ?? "-").toString();
        final childNm = (a["childName"] ?? "").toString();

        lastSosTime = createdAt.isEmpty ? "-" : createdAt;
        lastSosTrigger = trigger;

        if (lat != null && lng != null) {
          lastSosLocationUrl = "https://www.google.com/maps?q=$lat,$lng";
        } else {
          lastSosLocationUrl = "";
        }

        lastSosMessage = "SOS from ${childNm.isEmpty ? "your child" : childNm} ($trigger)";
      } else {
        // fallback local
        lastSosTime = localSosTime;
        lastSosLocationUrl = localSosLocation;
        lastSosMessage = localSosMessage;
        lastSosTrigger = "-";
      }
    } catch (_) {
      // fallback local
      lastSosTime = localSosTime;
      lastSosLocationUrl = localSosLocation;
      lastSosMessage = localSosMessage;
      lastSosTrigger = "-";
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _openMaps() async {
    if (lastSosLocationUrl.isEmpty) {
      _toast("No location saved yet.");
      return;
    }
    final uri = Uri.parse(lastSosLocationUrl);
    if (!await canLaunchUrl(uri)) {
      _toast("Could not open Maps link.");
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showInviteCodeDialog(String code) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invite Code"),
        content: SelectableText(
          code,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _generateInvite() async {
    try {
      final code = await FamilyService.generateInvite();
      if (code.trim().isEmpty) {
        _toast("Invite code is empty (backend issue).");
        return;
      }
      await _showInviteCodeDialog(code);
    } catch (e) {
      _toast("Failed to generate invite: $e");
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Do you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );

    if (ok != true) return;

    await AuthStorage.clear();
    await _goLogin();
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _BouncyIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.shield_rounded, color: Colors.white, size: 34),
                    const SizedBox(width: 10),
                    const Text(
                      "Silent Help",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    _chip("Parent Dashboard"),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 18),
                      children: [
                        const SizedBox(height: 6),
                        _title("Overview 👀"),
                        const SizedBox(height: 10),

                        _card(
                          title: "Account (Backend ✅)",
                          icon: Icons.account_circle_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Email", email),
                              const SizedBox(height: 8),
                              _kv("Name", parentName),
                              const SizedBox(height: 8),
                              _kv("Phone 1 (local)", phone1),
                              const SizedBox(height: 8),
                              _kv("Phone 2 (local)", phone2 == "-" ? "Not set" : phone2),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Child Information (UI temp ⏳)",
                          icon: Icons.child_care_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Name", childName),
                              const SizedBox(height: 8),
                              _kv("Gender", childGender),
                              const SizedBox(height: 8),
                              _kv("Birthday", childDob),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Parent Information (mixed)",
                          icon: Icons.family_restroom_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Name (backend)", parentName),
                              const SizedBox(height: 8),
                              _kv("Role (local)", parentRole),
                              const SizedBox(height: 8),
                              _kv("Birthday (local)", parentDob),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Last SOS (Backend ✅)",
                          icon: Icons.warning_rounded,
                          accent: Colors.red,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Time", lastSosTime),
                              const SizedBox(height: 8),
                              _kv("Trigger", lastSosTrigger),
                              const SizedBox(height: 8),
                              _kv("Message", lastSosMessage),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _openMaps,
                                  icon: const Icon(Icons.map_rounded, color: Colors.white),
                                  label: const Text(
                                    "Open Location in Maps",
                                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2F6BFF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Alerts (Backend ✅)",
                          icon: Icons.notifications_active_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Total", _alerts.length.toString()),
                              const SizedBox(height: 10),
                              if (_alerts.isEmpty)
                                Text(
                                  "No alerts yet.",
                                  style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700),
                                )
                              else
                                ..._alerts.take(3).map((a) {
                                  final t = (a["createdAt"] ?? "").toString();
                                  final trig = (a["triggerType"] ?? "").toString();
                                  final cn = (a["childName"] ?? "").toString();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "• $t — ${cn.isEmpty ? "Child" : cn} ($trig)",
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _generateInvite,
                            icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
                            label: const Text(
                              "Generate Invite Code",
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2F6BFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            label: const Text(
                              "Logout",
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.35),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            "Pull down to refresh ✅",
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w900,
      shadows: [Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 3))],
    ),
  );

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accent,
  }) {
    final a = accent ?? const Color(0xff2F6BFF);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: a.withOpacity(0.18), blurRadius: 22, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: a.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: a, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(k, style: TextStyle(color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 7,
          child: Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

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
              BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
