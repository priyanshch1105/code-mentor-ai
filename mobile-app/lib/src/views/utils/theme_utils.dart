import 'package:flutter/material.dart';
import 'app_palette.dart';

class ThemeUtils {
  /// Get color palette based on current theme
  static ColorSet getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? ColorSet.dark : ColorSet.light;
  }

  /// Get a specific color based on brightness
  static Color getColor(
    BuildContext context,
    Color lightColor,
    Color darkColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }
}

class ColorSet {
  final Color primary;
  final Color success;
  final Color warning;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;

  ColorSet({
    required this.primary,
    required this.success,
    required this.warning,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
  });

  static ColorSet light = ColorSet(
    primary: AppPalette.lightPrimary,
    success: AppPalette.lightSuccess,
    warning: AppPalette.lightWarning,
    secondary: AppPalette.lightSecondary,
    background: AppPalette.lightBackground,
    surface: AppPalette.lightSurface,
    textPrimary: AppPalette.lightTextPrimary,
    textSecondary: AppPalette.lightTextSecondary,
    border: AppPalette.lightBorder,
    divider: AppPalette.lightDivider,
  );

  static ColorSet dark = ColorSet(
    primary: AppPalette.darkPrimary,
    success: AppPalette.darkSuccess,
    warning: AppPalette.darkWarning,
    secondary: AppPalette.darkSecondary,
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    textPrimary: AppPalette.darkTextPrimary,
    textSecondary: AppPalette.darkTextSecondary,
    border: AppPalette.darkBorder,
    divider: AppPalette.darkDivider,
  );
}
