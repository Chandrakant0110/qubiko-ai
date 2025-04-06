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

  // Auth screen gradient colors
  static const Color authGradientStart = Color(0xFF8FBFFF);
  static const Color authGradientEnd = Color(0xFFFFDAF4);

  // Social login button colors
  static const Color facebookBlue = Color(0xFF2AA4F4);
  static const Color facebookDarkBlue = Color(0xFF007AD9);
  static const Color googleRed = Color(0xFFEB4335);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);

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

  // Auth screen background gradient
  static const LinearGradient authBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      authGradientStart,
      authGradientEnd,
    ],
  );

  // Button shadows
  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: Color(0x197483F4),
      blurRadius: 24,
      offset: Offset(4, 8),
    ),
  ];

  // Light theme color scheme
  static ColorScheme get lightColorScheme => const ColorScheme(
        primary: primaryLightBlue,
        primaryContainer: primaryDarkBlue,
        secondary: primaryDarkBlue,
        secondaryContainer: primaryLightBlue,
        surface: backgroundWhite,
        error: errorRed,
        onPrimary: backgroundWhite,
        onSecondary: backgroundWhite,
        onSurface: textDark,
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
        error: errorRed,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textLight,
        onError: backgroundDark,
        brightness: Brightness.dark,
      );
}
