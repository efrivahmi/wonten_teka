import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme getTextTheme() {
    return GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        // display-lg
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02 * 32, // -0.02em
          color: AppColors.onSurface,
          height: 40 / 32,
        ),
        // headline-lg
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01 * 24, // -0.01em
          color: AppColors.onSurface,
          height: 32 / 24,
        ),
        // headline-md
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01 * 22,
          color: AppColors.onSurface,
          height: 28 / 22,
        ),
        // body-lg
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 28 / 18,
        ),
        // body-md
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          height: 24 / 16,
        ),
        // label-md
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.01 * 14,
          color: AppColors.onSurface,
          height: 20 / 14,
        ),
        // label-sm
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          height: 16 / 12,
        ),
      ),
    );
  }
}
