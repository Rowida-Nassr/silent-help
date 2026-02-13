import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_background.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Child
  final _childNameCtrl = TextEditingController();
  String _childGender = "Boy";
  DateTime? _childDob;

  // Parent
  final _parentNameCtrl = TextEditingController();
  String _parentRole = "Mother";
  DateTime? _parentDob;

  // Contacts
  final _phone1Ctrl = TextEditingController(); // main SOS phone
  final _phone2Ctrl = TextEditingController();

  // Auth
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _saving = false;

  @override
  void dispose() {
    _childNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }

  Future<void> _pickChildDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _childDob ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(2005),
      lastDate: now,
    );
    if (picked != null) setState(() => _childDob = picked);
  }

  Future<void> _pickParentDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parentDob ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _parentDob = picked);
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

  bool _looksLikePhone(String s) {
    final v = _digitsOnly(s);
    // بسيط: رقم يبدأ + أو رقم محلي، وطوله معقول
    if (v.isEmpty) return false;
    if (v.startsWith('+')) return v.length >= 10 && v.length <= 16;
    return v.length >= 10 && v.length <= 15;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_childDob == null) {
      _toast("Please select Child birthday.");
      return;
    }
    if (_parentDob == null) {
      _toast("Please select Parent birthday.");
      return;
    }

    setState(() => _saving = true);

    // ✅ UI only الآن: حفظ محلي
    final prefs = await SharedPreferences.getInstance();

    // مهم لزر SOS
    await prefs.setString('parent_phone', _digitsOnly(_phone1Ctrl.text.trim()));
    await prefs.setString('parent_phone_2', _digitsOnly(_phone2Ctrl.text.trim()));

    // باقي البيانات (اختياري للتجربة)
    await prefs.setString('child_name', _childNameCtrl.text.trim());
    await prefs.setString('child_gender', _childGender);
    await prefs.setString('child_dob', _fmtDate(_childDob!));

    await prefs.setString('parent_name', _parentNameCtrl.text.trim());
    await prefs.setString('parent_role', _parentRole);
    await prefs.setString('parent_dob', _fmtDate(_parentDob!));

    await prefs.setString('parent_email_ui', _emailCtrl.text.trim());

    setState(() => _saving = false);

    _toast("Saved ✅ (UI only). You can login later when we add Firebase Auth.");
    Navigator.pop(context);
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

                // 🔝 Top bar
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Parent Register 📝",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create Parent Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 3)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fill the details to receive SOS alerts.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Form card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Child Information 👶"),

                            TextFormField(
                              controller: _childNameCtrl,
                              decoration: _inputDeco("Child name", Icons.badge_rounded),
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return "Child name is required";
                                if (s.length < 2) return "Enter a valid name";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _childGender,
                                    items: const [
                                      DropdownMenuItem(value: "Boy", child: Text("Boy")),
                                      DropdownMenuItem(value: "Girl", child: Text("Girl")),
                                    ],
                                    onChanged: (v) => setState(() => _childGender = v ?? "Boy"),
                                    decoration: _inputDeco("Child gender", Icons.wc_rounded),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _dateField(
                                    label: "Child birthday",
                                    value: _childDob == null ? "Select date" : _fmtDate(_childDob!),
                                    icon: Icons.cake_rounded,
                                    onTap: _pickChildDob,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),
                            _divider(),

                            _sectionTitle("Parent Information 👨‍👩‍👧"),

                            TextFormField(
                              controller: _parentNameCtrl,
                              decoration: _inputDeco("Parent name", Icons.person_rounded),
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return "Parent name is required";
                                if (s.length < 2) return "Enter a valid name";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _parentRole,
                                    items: const [
                                      DropdownMenuItem(value: "Mother", child: Text("Mother")),
                                      DropdownMenuItem(value: "Father", child: Text("Father")),
                                    ],
                                    onChanged: (v) => setState(() => _parentRole = v ?? "Mother"),
                                    decoration: _inputDeco("Parent role", Icons.family_restroom_rounded),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _dateField(
                                    label: "Parent birthday",
                                    value: _parentDob == null ? "Select date" : _fmtDate(_parentDob!),
                                    icon: Icons.cake_outlined,
                                    onTap: _pickParentDob,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),
                            _divider(),

                            _sectionTitle("Emergency Contacts 📞"),

                            TextFormField(
                              controller: _phone1Ctrl,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDeco(
                                "Phone 1 (main WhatsApp)",
                                Icons.phone_rounded,
                                helper: "This number will receive SOS first.",
                              ),
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return "Phone 1 is required";
                                if (!_looksLikePhone(s)) return "Enter a valid phone number";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _phone2Ctrl,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDeco(
                                "Phone 2 (backup)",
                                Icons.phone_in_talk_rounded,
                                helper: "Optional but recommended.",
                              ),
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return null; // optional
                                if (!_looksLikePhone(s)) return "Enter a valid phone number";
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),
                            _divider(),

                            _sectionTitle("Account Login 🔐"),

                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDeco("Email", Icons.email_rounded),
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return "Email is required";
                                if (!s.contains("@")) return "Enter a valid email";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure1,
                              decoration: _inputDeco(
                                "Password",
                                Icons.lock_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                                  icon: Icon(_obscure1 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                ),
                              ),
                              validator: (v) {
                                final s = v ?? "";
                                if (s.isEmpty) return "Password is required";
                                if (s.length < 6) return "Min 6 characters";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscure2,
                              decoration: _inputDeco(
                                "Confirm password",
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                                  icon: Icon(_obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                ),
                              ),
                              validator: (v) {
                                final s = v ?? "";
                                if (s.isEmpty) return "Confirm your password";
                                if (s != _passCtrl.text) return "Passwords do not match";
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2F6BFF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 0,
                                ),
                                child: _saving
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : const Text(
                                  "Save",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Center(
                              child: Text(
                                "UI only الآن — هنربط Firebase Auth بعدين ✅",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    height: 1,
    color: Colors.black.withOpacity(0.08),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  );

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix, String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: value == "Select date" ? Colors.black.withOpacity(0.45) : Colors.black.withOpacity(0.85),
          ),
        ),
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
