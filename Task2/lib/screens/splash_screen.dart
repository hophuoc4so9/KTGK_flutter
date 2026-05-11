import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotuanphuoc_2224802010872_lab4/common/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/check');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.authBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_rounded, size: 80, color: Colors.white)
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: AppTheme.kSlow,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 24),
              Text(
                'Messenger',
                style: GoogleFonts.sora(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: AppTheme.kMedium)
                  .slideY(begin: 0.3, end: 0.0, duration: AppTheme.kMedium),
              const SizedBox(height: 10),
              Text(
                'Connect with everyone',
                style: GoogleFonts.sora(fontSize: 14, color: Colors.white60),
              ).animate(delay: 400.ms).fadeIn(duration: AppTheme.kMedium),
              const SizedBox(height: 48),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ).animate(delay: 600.ms).fadeIn(duration: AppTheme.kMedium),
            ],
          ),
        ),
      ),
    );
  }
}
