import 'package:flutter/material.dart';
import 'app_palette.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppPalette.lightPrimary,
    scaffoldBackgroundColor: AppPalette.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.lightPrimary,
      secondary: AppPalette.lightSecondary,
      tertiary: AppPalette.lightWarning,
      surface: AppPalette.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppPalette.lightTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.lightSurface,
      foregroundColor: AppPalette.lightTextPrimary,
      elevation: 1,
      shadowColor: AppPalette.lightBorder,
    ),
    cardTheme: CardThemeData(
      color: AppPalette.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.lightBackground,
      labelStyle: const TextStyle(color: AppPalette.lightTextPrimary),
      side: const BorderSide(color: AppPalette.lightBorder),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPalette.lightTextPrimary),
      bodyMedium: TextStyle(color: AppPalette.lightTextSecondary),
      bodySmall: TextStyle(color: AppPalette.lightTextSecondary, fontSize: 12),
      headlineSmall: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppPalette.lightTextPrimary,
      subtitleTextStyle: TextStyle(color: AppPalette.lightTextSecondary),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppPalette.darkPrimary,
    scaffoldBackgroundColor: AppPalette.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.darkPrimary,
      secondary: AppPalette.darkSecondary,
      tertiary: AppPalette.darkWarning,
      surface: AppPalette.darkSurface,
      onPrimary: AppPalette.darkBackground,
      onSecondary: AppPalette.darkBackground,
      onSurface: AppPalette.darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.darkSurface,
      foregroundColor: AppPalette.darkTextPrimary,
      elevation: 1,
      shadowColor: AppPalette.darkBorder,
    ),
    cardTheme: CardThemeData(
      color: AppPalette.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.darkBackground,
      labelStyle: const TextStyle(color: AppPalette.darkTextPrimary),
      side: const BorderSide(color: AppPalette.darkBorder),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPalette.darkTextPrimary),
      bodyMedium: TextStyle(color: AppPalette.darkTextSecondary),
      bodySmall: TextStyle(color: AppPalette.darkTextSecondary, fontSize: 12),
      headlineSmall: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppPalette.darkTextPrimary,
      subtitleTextStyle: TextStyle(color: AppPalette.darkTextSecondary),
    ),
  );
}
