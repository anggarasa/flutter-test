import 'package:flutter/material.dart';
import 'package:fluttertest/configs/theme/app_colors.dart';
import 'package:fluttertest/gen/fonts.gen.dart';

class AppThemes {
  static ThemeData light() => ThemeData(
    fontFamily: FontFamily.montserrat,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
