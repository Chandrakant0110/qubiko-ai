import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors from Figma
  static const Color primaryLightBlue = Color(0xFF7E92F8);
  static const Color primaryDarkBlue = Color(0xFF6972F0);
  
  // Text colors
  static const Color textDark = Color(0xFF212121);
  
  // Background colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  
  // Create a linear gradient based on the Figma design
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryLightBlue,
      primaryDarkBlue,
    ],
  );
} 