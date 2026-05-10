import 'package:flutter/material.dart';

class AppPalette {
  // Light Mode Colors - Matching frontend (blue/purple)
  static const Color lightPrimary = Color(0xFF4F46E5); // Indigo
  static const Color lightSuccess = Color(0xFF86EFAC); // Green
  static const Color lightWarning = Color(0xFFFDA4AF); // Red
  static const Color lightSecondary = Color(0xFFA5B4FC); // Purple
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate-50
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightTextPrimary = Color(0xFF1E293B); // Slate-900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate-200
  static const Color lightDivider = Color(0xFFCBD5E1); // Slate-300

  // Dark Mode Colors - Matching frontend
  static const Color darkPrimary = Color(0xFF93C5FD); // Blue-400
  static const Color darkSuccess = Color(0xFF4ADE80); // Green-500
  static const Color darkWarning = Color(0xFFFB7185); // Rose-500
  static const Color darkSecondary = Color(0xFFC4B5FD); // Purple-300
  static const Color darkBackground = Color(0xFF111827); // Gray-900
  static const Color darkSurface = Color(0xFF1F2937); // Gray-800
  static const Color darkTextPrimary = Color(0xFFE2E8F0); // Slate-100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color darkBorder = Color(0xFF334155); // Slate-700
  static const Color darkDivider = Color(0xFF475569); // Slate-600

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
