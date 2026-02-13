import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff6DD5FA),
                Color(0xff2980B9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // ☁️ Decorative Circles
        Positioned(
          top: -60,
          left: -40,
          child: _circle(220, Colors.white.withOpacity(0.14)),
        ),
        Positioned(
          bottom: -70,
          right: -50,
          child: _circle(250, Colors.white.withOpacity(0.12)),
        ),
        Positioned(
          top: 260,
          right: -70,
          child: _circle(170, Colors.white.withOpacity(0.10)),
        ),

        // Content
        child,
      ],
    );
  }

  static Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
