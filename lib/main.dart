import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash.dart';

void main() {
  // شلنا async و await firebase لأننا هنعتمد على الـ Backend الجديد
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SilentHelpApp());
}

class SilentHelpApp extends StatelessWidget {
  const SilentHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Help',
      theme: ThemeData(
        // استخدام Google Fonts مباشرة بيحتاج إنترنت في أول مرة
        // لو مفيش إنترنت ممكن التطبيق يعلق شوية في البداية
        textTheme: GoogleFonts.baloo2TextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff5B8CFF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}