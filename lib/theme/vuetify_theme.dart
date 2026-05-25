import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VuetifyTheme {
  // Extracted from production volleyballlife.com
  static const primaryDark = Color(0xFF0A2C46);
  static const primary = Color(0xFF1976D2);
  static const primaryLight = Color(0xFF42A5F5);
  static const cardBg = Color(0xFFB3C5D1);
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F5F5);
  static const cardShadow = Color(0x1A000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        error: error,
        primary: primary,
      ),
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
