import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Purple/Violet Theme
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B88FF);
  static const Color primaryDark = Color(0xFF5A4FCF);

  // Secondary Colors - Complementary Blue
  static const Color secondary = Color(0xFF00B894);
  static const Color secondaryLight = Color(0xFF00D4AA);
  static const Color secondaryDark = Color(0xFF00A085);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color accentDark = Color(0xFFE55555);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF2D3436);
  static const Color grey = Color(0xFF636E72);
  static const Color lightGrey = Color(0xFFDDD6FE);
  static const Color darkGrey = Color(0xFF2D3436);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFF74B9FF);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Social Media Specific Colors
  static const Color like = Color(0xFFE84393);
  static const Color comment = Color(0xFF00B894);
  static const Color share = Color(0xFF6C5CE7);
  static const Color bookmark = Color(0xFFFDCB6E);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
}
