import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Reference Image Aesthetic: Crisp Modern Light Theme ──
  static const Color bgCanvas = Color(0xFFF8FAFC);        // Slate 50 canvas background
  static const Color cardSurface = Color(0xFFFFFFFF);     // Pure white cards
  static const Color bgElevated = Color(0xFFF1F5F9);      // Slate 100
  
  static const Color primaryGreen = Color(0xFF10B981);     // Vibrant emerald green
  static const Color primaryGreenDark = Color(0xFF047857); // Deep forest green
  static const Color accentEmerald = Color(0xFF10B981);    // Accent emerald green
  static const Color greenLightBg = Color(0xFFECFDF5);     // Light emerald tint
  static const Color greenBorder = Color(0xFFA7F3D0);      // Soft green border

  static const Color accentBlue = Color(0xFF3B82F6);       // Royal blue
  static const Color blueLightBg = Color(0xFFEFF6FF);      // Soft blue tint
  static const Color blueBorder = Color(0xFFBFDBFE);       // Blue border

  static const Color accentOrange = Color(0xFFF97316);     // Bright orange
  static const Color orangeLightBg = Color(0xFFFFF7ED);    // Soft orange tint
  static const Color orangeBorder = Color(0xFFFED7AA);     // Orange border

  static const Color accentPurple = Color(0xFF8B5CF6);     // Soft purple
  static const Color purpleLightBg = Color(0xFFF5F3FF);    // Soft purple tint
  static const Color purpleBorder = Color(0xFFDDD6FE);     // Purple border

  static const Color accentRed = Color(0xFFEF4444);        // Warning red
  static const Color redLightBg = Color(0xFFFEF2F2);       // Red tint

  static const Color textPrimary = Color(0xFF0F172A);      // Slate 900
  static const Color textSecondary = Color(0xFF475569);    // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);        // Slate 400

  static const Color borderLight = Color(0xFFE2E8F0);      // Slate 200 light border
  static const Color borderSubtle = Color(0xFFCBD5E1);     // Slate 300 subtle border

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgCanvas,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentBlue,
        surface: cardSurface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textPrimary, fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textMuted),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: textPrimary, fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
