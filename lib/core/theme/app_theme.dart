import 'package:flutter/material.dart';

/// Sawad Finnix brand colors.
class AppColors {
  AppColors._();

  /// Main brand color (#db771a).
  static const Color primary = Color(0xFFDB771A);
  static const Color primaryDark = Color(0xFFB85F12);

  /// Accent shares the main brand color (used on the balance card gradient).
  static const Color accent = Color(0xFFDB771A);
  static const Color accentDark = Color(0xFFB85F12);

  /// Soft background (#fcefe4).
  static const Color background = Color(0xFFFCEFE4);
  static const Color surface = Colors.white;

  /// Primary text color (#003063).
  static const Color textPrimary = Color(0xFF003063);
  static const Color textBody = Color(0xFF2D3A4F);
  static const Color textMuted = Color(0xFF8A90A6);
  static const Color divider = Color(0xFFEADBCB);

  /// Banner shown in UAT builds.
  static const Color uatBanner = Color(0xFFB85F12);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
