import 'package:flutter/material.dart';
import '../services/family_service.dart';
import 'child_home.dart';
import 'app_background.dart';

class ChildJoinFamilyScreen extends StatefulWidget {
  const ChildJoinFamilyScreen({super.key});

  @override
  State<ChildJoinFamilyScreen> createState() => _ChildJoinFamilyScreenState();
}

class _ChildJoinFamilyScreenState extends State<ChildJoinFamilyScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _toast("Enter invite code");
      return;
    }

    setState(() => _loading = true);
    try {
      await FamilyService.joinFamily(inviteCode: code);
      if (!mounted) return;
      _toast("Joined successfully ✅");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
      );
    } catch (e) {
      _toast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
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
                        "Join Family 🔗",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Link to Parent ✅",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter the invite code from Parent Dashboard",
                        style: TextStyle(color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _codeCtrl,
                        decoration: InputDecoration(
                          labelText: "Invite Code",
                          prefixIcon: const Icon(Icons.key_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _join,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2F6BFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Text(
                            "Join",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
