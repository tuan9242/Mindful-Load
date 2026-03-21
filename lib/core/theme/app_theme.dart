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
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
      ),
    );
  }
}
