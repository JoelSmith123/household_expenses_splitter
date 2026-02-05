import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF228B22);
  static const Color deepGreen = Color(0xFF196719);
  static const Color cream = Color(0xFFF9F5D2);
  static const Color ink = Color(0xFF1B1B1B);
  static const Color muted = Color(0xFF6B6B6B);
}

class AppText {
  static TextStyle title() {
    return GoogleFonts.modak(
      fontSize: 36,
      color: AppColors.primaryGreen,
    );
  }

  static TextStyle headline() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    );
  }

  static TextStyle body() {
    return const TextStyle(
      fontSize: 16,
      color: AppColors.ink,
    );
  }

  static TextStyle caption() {
    return const TextStyle(
      fontSize: 13,
      color: AppColors.muted,
    );
  }
}

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
