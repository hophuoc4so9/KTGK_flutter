import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9B97F5);
  static const Color navyDark = Color(0xFF1A1A2E);
  static const Color background = Color(0xFFF6F6FB);
  static const Color surface = Colors.white;
  static const Color receivedBubble = Color(0xFFF3F4F6);
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);

  // Gradients
  static const LinearGradient sentBubbleGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient authBackgroundGradient = LinearGradient(
    colors: [navyDark, Color(0xFF16213E), Color(0xFF0F3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient settingsHeaderGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text styles
  static TextStyle get headingLarge => GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get headingMedium => GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: navyDark,
      );

  static TextStyle get bodyMedium => GoogleFonts.sora(
        fontSize: 14,
        color: Colors.black87,
      );

  static TextStyle get caption => GoogleFonts.sora(
        fontSize: 12,
        color: Colors.grey,
      );

  // Shared input decoration factory
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
    );
  }

  // MaterialApp ThemeData
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        textTheme: GoogleFonts.soraTextTheme(),
        scaffoldBackgroundColor: background,
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          elevation: 0.5,
          titleTextStyle: GoogleFonts.sora(
            color: navyDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: navyDark),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: surface,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size.fromHeight(52),
            textStyle: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: navyDark,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size.fromHeight(52),
            textStyle: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  // Animation duration constants
  static const Duration kFast = Duration(milliseconds: 200);
  static const Duration kMedium = Duration(milliseconds: 350);
  static const Duration kSlow = Duration(milliseconds: 500);

  // Chat background
  static const Color kChatBackground = Color(0xFFF0F0F8);

  // Custom slide+fade page transition
  static Route<T> pageTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, a, _) => page,
      transitionDuration: kMedium,
      reverseTransitionDuration: kFast,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: FadeTransition(
          opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
          child: child,
        ),
      ),
    );
  }
}
