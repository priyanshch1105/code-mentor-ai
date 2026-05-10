import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_palette.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.light,
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
      surface: AppPalette.lightSurface,
    );

    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: AppPalette.lightBg,
      dividerColor: AppPalette.lightBorder,
      cardTheme: const CardThemeData(
        color: AppPalette.lightSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF60A5FA),
      secondary: const Color(0xFF93C5FD),
      surface: AppPalette.darkSurface,
    );

    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: AppPalette.darkBg,
      dividerColor: AppPalette.darkBorder,
      cardTheme: const CardThemeData(
        color: AppPalette.darkSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.spaceGroteskTextTheme(),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }
}
