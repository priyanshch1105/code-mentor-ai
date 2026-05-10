import 'package:flutter/material.dart';

class AppPalette {
  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF0B6E4F);
  static const Color lightSuccess = Color(0xFF34A853);
  static const Color lightWarning = Color(0xFFB26B00);
  static const Color lightSecondary = Color(0xFF8F2D56);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFBDBDBD);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFF4DB8A8);
  static const Color darkSuccess = Color(0xFF81C995);
  static const Color darkWarning = Color(0xFFF4A460);
  static const Color darkSecondary = Color(0xFFD897B8);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkBorder = Color(0xFF373737);
  static const Color darkDivider = Color(0xFF424242);

  // Legacy access (defaults to light mode)
  static const Color primary = lightPrimary;
  static const Color success = lightSuccess;
  static const Color warning = lightWarning;
  static const Color secondary = lightSecondary;
}

extension ColorHelpers on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return Color.fromARGB((alpha * 255).toInt(), red, green, blue);
  }
}
