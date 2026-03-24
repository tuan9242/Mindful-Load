import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF121929);
  static const Color surfaceCard = Color(0xFF1A2236);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryGlow = Color(0x332563EB);
  static const Color accent = Color(0xFF00D4FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFADB5C8);
  static const Color textMuted = Color(0xFF6B7A99);
  static const Color borderColor = Color(0xFF1E2D47);
  static const Color selectedBg = Color(0xFF1E3A6E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surfaceCard,
      hintColor: textMuted,
      dividerColor: borderColor,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 15),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 13),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      primaryColor: primary,
      cardColor: Colors.white,
      hintColor: Colors.grey,
      dividerColor: Colors.grey.shade200,
      fontFamily: 'sans-serif',
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: Colors.white,
        onSurface: Colors.black,
        onPrimary: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 15),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 13),
        bodySmall: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: Color(0xFF4B5563)),
      ),
    );
  }
}
