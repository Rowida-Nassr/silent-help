import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../services/family_service.dart';
import 'child_home.dart';
import 'app_background.dart';

class ChildRegisterScreen extends StatefulWidget {
  const ChildRegisterScreen({super.key});

  @override
  State<ChildRegisterScreen> createState() => _ChildRegisterScreenState();
}

class _ChildRegisterScreenState extends State<ChildRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _invite = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _invite.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _registerAndJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1) Register Child
      final res = await AuthService.register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: "child",
        phone: null,
      );

      final token = (res["token"] ?? "").toString();
      final user = res["user"];

      if (token.isEmpty || user is! Map) {
        throw Exception("Register response missing token/user");
      }

      final role = (user["role"] ?? "").toString();
      if (role != "child") {
        throw Exception("This registration is for Child only.");
      }

      await AuthStorage.saveAuth(
        token: token,
        role: role,
        email: (user["email"] ?? "").toString(),
        name: (user["fullName"] ?? "").toString(),
        userId: (user["id"] ?? "").toString(),
      );

      // 2) Join Family using invite code
      final code = _invite.text.trim();
      await FamilyService.joinFamily(inviteCode: code);

      if (!mounted) return;
      _toast("Child registered + linked ✅");

      // 3) Go to child home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
        (_) => false,
      );
    } catch (e) {
      _toast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
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
                        "Child Register 🧒",
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Create Child Account",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Enter Invite Code from Parent Dashboard",
                          style: TextStyle(color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: const Icon(Icons.person_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.isEmpty) return "Name is required";
                            if (s.length < 2) return "Enter a valid name";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.isEmpty) return "Email is required";
                            if (!s.contains("@")) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (v) {
                            final s = (v ?? "");
                            if (s.isEmpty) return "Password is required";
                            if (s.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _invite,
                          decoration: InputDecoration(
                            labelText: "Invite Code",
                            prefixIcon: const Icon(Icons.qr_code_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.isEmpty) return "Invite code is required";
                            if (s.length < 4) return "Invite code looks too short";
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _registerAndJoin,
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
                                    "Register & Link",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
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
}
