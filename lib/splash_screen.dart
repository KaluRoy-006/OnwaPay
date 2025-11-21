import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart'; // Replace with your actual homepage

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animate logo
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Navigate after splash
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final shimmerPosition = _controller.value * 2 - 1;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + shimmerPosition, -1),
                end: Alignment(1 + shimmerPosition, 1),
                colors: const [
                  Color(0xFF001F3F), // Deep navy blue
                  Color(0xFF002B5B), // Slightly lighter blue
                  Color(0xFFFFD700), // Gold highlight
                  Color(0xFF001F3F),
                ],
                stops: const [0.0, 0.4, 0.6, 1.0],
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/OnwaPay_logo.jpg',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "OnwaPay",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700), // Gold text
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
