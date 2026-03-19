import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Text styles with Urbanist font
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.25,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = AppColors.lightColorScheme;
    final TextTheme textTheme = _buildTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = AppColors.darkColorScheme;
    final TextTheme textTheme = _buildTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundDarkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
