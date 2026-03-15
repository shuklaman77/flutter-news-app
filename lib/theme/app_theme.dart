import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color secondaryColor = Color(0xFF16213E);
  static const Color accentColor = Color(0xFFE94560);
  static const Color accentLight = Color(0xFFFF6B6B);
  static const Color surfaceColor = Color(0xFF0F3460);
  static const Color cardColor = Color(0xFF1E2A4A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D4);
  static const Color textTertiary = Color(0xFF6B7594);
  static const Color chipBackground = Color(0xFF2A3A5C);
  static const Color shimmerBase = Color(0xFF1E2A4A);
  static const Color shimmerHighlight = Color(0xFF2A3A5C);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentLight,
        surface: secondaryColor,
        background: primaryColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: primaryColor,
      fontFamily: 'PlusJakartaSans', // <-- default app font

      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textPrimary,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textPrimary,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: chipBackground,
        selectedColor: accentColor,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          fontFamily: 'PlusJakartaSans',
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'PlusJakartaSans',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: textTertiary,
          fontFamily: 'PlusJakartaSans',
        ),
        prefixIconColor: textTertiary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: 'PlusJakartaSans',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}