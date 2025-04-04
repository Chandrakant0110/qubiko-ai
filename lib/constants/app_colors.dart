import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primaryLightBlue = Color(0xFF7E92F8);
  static const Color primaryDarkBlue = Color(0xFF6972F0);

  // Text colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFAFAFA);
  static const Color textSecondaryLight = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF757575);

  // Background colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color backgroundDarkGrey = Color(0xFF1E1E1E);

  // Common UI element colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningYellow = Color(0xFFFFB300);
  static const Color infoBlue = Color(0xFF2196F3);

  // Create a linear gradient based on the Figma design
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryLightBlue,
      primaryDarkBlue,
    ],
  );

  // Light theme color scheme
  static ColorScheme get lightColorScheme => const ColorScheme(
        primary: primaryLightBlue,
        primaryContainer: primaryDarkBlue,
        secondary: primaryDarkBlue,
        secondaryContainer: primaryLightBlue,
        surface: backgroundWhite,
        background: backgroundWhite,
        error: errorRed,
        onPrimary: backgroundWhite,
        onSecondary: backgroundWhite,
        onSurface: textDark,
        onBackground: textDark,
        onError: backgroundWhite,
        brightness: Brightness.light,
      );

  // Dark theme color scheme
  static ColorScheme get darkColorScheme => const ColorScheme(
        primary: primaryLightBlue,
        primaryContainer: primaryDarkBlue,
        secondary: primaryDarkBlue,
        secondaryContainer: primaryLightBlue,
        surface: backgroundDark,
        background: backgroundDark,
        error: errorRed,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textLight,
        onBackground: textLight,
        onError: backgroundDark,
        brightness: Brightness.dark,
      );
}
