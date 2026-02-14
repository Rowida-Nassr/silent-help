import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_background.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _loading = true;

  // Stored values
  String childName = "-";
  String childGender = "-";
  String childDob = "-";

  String parentName = "-";
  String parentRole = "-";
  String parentDob = "-";

  String phone1 = "-";
  String phone2 = "-";
  String email = "-";

  String lastSosTime = "-";
  String lastSosLocationUrl = "";
  String lastSosMessage = "-";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();

    childName = prefs.getString('child_name') ?? "-";
    childGender = prefs.getString('child_gender') ?? "-";
    childDob = prefs.getString('child_dob') ?? "-";

    parentName = prefs.getString('parent_name') ?? "-";
    parentRole = prefs.getString('parent_role') ?? "-";
    parentDob = prefs.getString('parent_dob') ?? "-";

    phone1 = prefs.getString('parent_phone') ?? "-";
    phone2 = prefs.getString('parent_phone_2') ?? "-";
    email = prefs.getString('parent_email_ui') ?? "-";

    lastSosTime = prefs.getString('last_sos_time') ?? "-";
    lastSosLocationUrl = prefs.getString('last_sos_location_url') ?? "";
    lastSosMessage = prefs.getString('last_sos_message') ?? "-";

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

    final prefs = await SharedPreferences.getInstance();
    // UI-only logout flag
    await prefs.setBool('parent_logged_in', false);

    if (!mounted) return;
    Navigator.pop(context); // يرجع للي قبلها (Role Select أو Parent Login)
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

                // Top bar
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

                // Content
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
                          title: "Account",
                          icon: Icons.account_circle_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Email", email),
                              const SizedBox(height: 8),
                              _kv("Phone 1", phone1),
                              const SizedBox(height: 8),
                              _kv("Phone 2", phone2 == "-" ? "Not set" : phone2),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Child Information",
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
                          title: "Parent Information",
                          icon: Icons.family_restroom_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Name", parentName),
                              const SizedBox(height: 8),
                              _kv("Role", parentRole),
                              const SizedBox(height: 8),
                              _kv("Birthday", parentDob),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          title: "Last SOS 🚨",
                          icon: Icons.warning_rounded,
                          accent: Colors.red,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv("Time", lastSosTime),
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
          BoxShadow(
            color: a.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          )
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
                decoration: BoxDecoration(
                  color: a.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: a, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
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
          child: Text(
            k,
            style: TextStyle(color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 7,
          child: Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
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
