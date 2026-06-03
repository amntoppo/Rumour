import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rumour_app/core/routes/route_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to the room screen after 2.5 seconds
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteName.roomScreen);
      }
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
      backgroundColor: const Color(0xFF0B0F19),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Color(0xFF1E293B), // Dark slate blue
              Color(0xFF0F172A), // Very dark slate
              Color(0xFF020617), // Near black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing key icon container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFA3E635,
                              ).withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(
                              0xFFA3E635,
                            ).withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/room_key.svg',
                          width: 80,
                          height: 40,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFA3E635),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name with gradient/shadow style
                      Text(
                        'RUMOUR',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFFA3E635,
                              ).withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Anonymous Room Chat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                          color: Colors.white.withValues(alpha: 0.5),
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
    );
  }
}
