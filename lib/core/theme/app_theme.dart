import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors defined strictly here
  static const Color darkBackground = Color(0xFF212327);
  static const Color darkSurface = Color(0xFF232627);
  static const Color darkSurfaceElevated = Color(0xFF2A2D32);
  static const Color darkTextPrimary = Color(0xFFCDCCCA);
  static const Color darkTextSecondary = Color(0xFF8E8D8B);
  static const Color darkBorder = Color(0x14FFFFFF); // 8% white

  static const Color lightBackground = Color(0xFFEFEEF1);
  static const Color lightSurface = Color(0xFFFEFEFE);
  static const Color lightSurfaceElevated = Color(0xFFF4F3F6);
  static const Color lightTextPrimary = Color(0xFF212327);
  static const Color lightTextSecondary = Color(0xFF6E6D6B);
  static const Color lightBorder = Color(0x0F000000); // 6% black

  static const Color accentTeal = Color(0xFF3FC8B0);
  static const Color accentTealGlow = Color(0x283FC8B0);
  static const Color accentOnTeal = Color(0xFF141718);

  static const Color statusDone = Color(0xFF3FC8B0);
  static const Color statusProcessing = Color(0xFF4DAAF8);
  static const Color statusWaiting = Color(0xFF8E8D8B);
  static const Color statusError = Color(0xFFE05252);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentTeal,
      onPrimary: accentOnTeal,
      secondary: accentTeal,
      onSecondary: accentOnTeal,
      error: statusError,
      onError: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurfaceElevated,
      onSurfaceVariant: darkTextSecondary,
      outline: darkBorder,
      outlineVariant: accentTealGlow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: colorScheme,
      cardColor: darkSurface,
      dividerColor: darkBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkSurface,
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentTeal;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(accentOnTeal),
        side: const BorderSide(color: darkTextSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentTeal,
        inactiveTrackColor: darkSurfaceElevated,
        thumbColor: accentTeal,
        overlayColor: accentTealGlow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary, fontSize: 13),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: accentTeal,
      onPrimary: accentOnTeal,
      secondary: accentTeal,
      onSecondary: accentOnTeal,
      error: statusError,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: lightSurfaceElevated,
      onSurfaceVariant: lightTextSecondary,
      outline: lightBorder,
      outlineVariant: accentTealGlow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: colorScheme,
      cardColor: lightSurface,
      dividerColor: lightBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightSurface,
          foregroundColor: lightTextPrimary,
          side: const BorderSide(color: lightBorder, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          side: const BorderSide(color: lightBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentTeal;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(accentOnTeal),
        side: const BorderSide(color: lightTextSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentTeal,
        inactiveTrackColor: lightSurfaceElevated,
        thumbColor: accentTeal,
        overlayColor: accentTealGlow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lightTextSecondary, fontSize: 13),
      ),
    );
  }
}
