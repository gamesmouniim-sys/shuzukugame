import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF7F7F9);
  static const Color backgroundAmoled = Color(0xFFFFFFFF);
  static const Color backgroundPurple = Color(0xFFF1F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F3F6);
  static const Color accent = Color(0xFF356AE6);
  static const Color accentGlow = Color(0x33356AE6);
  static const Color accentBlue = Color(0xFF1D9BF0);
  static const Color accentPurple = Color(0xFF7C6EF6);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentPink = Color(0xFFE96BA8);
  static const Color accentRed = Color(0xFFE25555);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF666A73);
  static const Color textMuted = Color(0xFF8B9098);
  static const Color border = Color(0xFFE1E4E8);
  static const Color glassBorder = Color(0xFFE1E4E8);
  static const Color glassBackground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2B8A57);
  static const Color error = Color(0xFFD64545);
  static const Color warning = Color(0xFFE7A12B);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.accentPurple,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent;
            }
            return Colors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentGlow;
            }
            return const Color(0xFFD8DCE3);
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.surfaceLight,
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accentGlow,
          trackHeight: 4,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF25272B),
          contentTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
