import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'role_select.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _loop;   // loops for bubbles, glow, dots
  late final AnimationController _intro;  // one-time entrance

  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;
  late final Animation<double> _floatY;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();

    _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    _logoScale = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _loop, curve: Curves.easeInOutBack),
    );

    _logoGlow = Tween<double>(begin: 0.10, end: 0.22).animate(
      CurvedAnimation(parent: _loop, curve: Curves.easeInOut),
    );

    _floatY = Tween<double>(begin: -14, end: 14).animate(
      CurvedAnimation(parent: _loop, curve: Curves.easeInOut),
    );

    _introFade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);

    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const RoleSelectScreen()),
        ),
      );
    });
  }

  @override
  void dispose() {
    _loop.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_loop, _intro]),
        builder: (_, __) {
          final fy = _floatY.value;

          return Stack(
            children: [
              // 🎨 Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffFFDEE9), // pink
                      Color(0xffB5FFFC), // mint
                      Color(0xffA1C4FD), // baby blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // ☁️ Soft bubbles (parallax)
              _bubble(left: -30, top: 90 + fy, size: 170, opacity: 0.18),
              _bubble(left: 260, top: 120 - fy, size: 95, opacity: 0.22),
              _bubble(left: 235, top: 520 + fy, size: 140, opacity: 0.16),
              _bubble(left: 30, top: 540 - fy, size: 90, opacity: 0.18),
              _bubble(left: 40, top: 250 - fy, size: 120, opacity: 0.14),

              // ⭐ tiny sparkles
              _sparkle(left: 70, top: 165 - fy, size: 18, opacity: 0.35),
              _sparkle(left: 310, top: 245 + fy, size: 16, opacity: 0.30),
              _sparkle(left: 260, top: 70 + fy, size: 14, opacity: 0.28),
              _sparkle(left: 120, top: 650 + fy, size: 16, opacity: 0.25),

              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _introFade,
                    child: SlideTransition(
                      position: _introSlide,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🛡 Logo with glow + breathing
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 175,
                                height: 175,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(_logoGlow.value),
                                      blurRadius: 38,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              ScaleTransition(
                                scale: _logoScale,
                                child: Container(
                                  width: 135,
                                  height: 135,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.96),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 22,
                                        offset: const Offset(0, 12),
                                      )
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.shield_rounded,
                                      size: 76,
                                      color: Color(0xff2F6BFF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Title (more readable)
                          const Text(
                            "Silent Help",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle (clear)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Text(
                              "Stay safe • Tap SOS anytime",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Loading dots (cute)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _dot(_loop.value, 0),
                              _dot(_loop.value, 1),
                              _dot(_loop.value, 2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- helpers ----------

  Widget _bubble({
    required double left,
    required double top,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _sparkle({
    required double left,
    required double top,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  static Widget _dot(double t, int i) {
    // small wave motion per dot
    final v = sin((t * 2 * pi) + (i * 1.2));
    final dy = v * 4;

    return Transform.translate(
      offset: Offset(0, dy),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
      ),
    );
  }
}
