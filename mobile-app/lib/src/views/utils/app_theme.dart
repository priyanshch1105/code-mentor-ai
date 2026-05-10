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
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppPalette.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.lightBackground,
      labelStyle: const TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppPalette.lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: AppPalette.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: AppPalette.lightTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppPalette.lightTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: AppPalette.lightTextSecondary, fontSize: 12),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppPalette.lightTextPrimary,
      subtitleTextStyle: TextStyle(color: AppPalette.lightTextSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.lightPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppPalette.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.darkBackground,
      labelStyle: const TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppPalette.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: AppPalette.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: AppPalette.darkTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppPalette.darkTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: AppPalette.darkTextSecondary, fontSize: 12),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppPalette.darkTextPrimary,
      subtitleTextStyle: TextStyle(color: AppPalette.darkTextSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.darkPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
