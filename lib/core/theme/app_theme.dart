import 'package:flutter/material.dart';

class AppTheme {
  // Supabase-style Dark Theme Colors (Original)
  static const Color primaryGreen = Color(0xFF3ECF8E); // Supabase Green
  static const Color primaryGreenLight = Color(0xFF5DE4A5);
  static const Color primaryGreenDark = Color(0xFF2EB47B);

  // Dark Background Colors
  static const Color backgroundDark = Color(0xFF1C1C1C); // Main background
  static const Color surfaceDark = Color(0xFF232323); // Card surfaces
  static const Color surfaceDarkLighter = Color(
    0xFF2A2A2A,
  ); // Elevated surfaces
  static const Color surfaceDarkHover = Color(0xFF333333); // Hover states

  // Text Colors
  static const Color textPrimary = Color(0xFFEDEDED); // Main text
  static const Color textSecondary = Color(0xFF8F8F8F); // Secondary text
  static const Color textMuted = Color(0xFF6B6B6B); // Muted text

  // Border Colors
  static const Color borderDark = Color(0xFF333333);
  static const Color borderDarkLight = Color(0xFF404040);

  // Accent Colors
  static const Color accentGreen = Color(
    0xFF3ECF8E,
  ); // Success (same as primary)
  static const Color accentOrange = Color(0xFFF59E0B); // Warning
  static const Color accentRed = Color(0xFFEF4444); // Error
  static const Color accentBlue = Color(0xFF3B82F6); // Info
  static const Color accentYellow = Color(0xFFEAB308); // Yellow
  static const Color accentPurple = Color(0xFF8B5CF6); // Purple

  // Chart Colors (Supabase style)
  static const Color chartGreen = Color(0xFF3ECF8E);
  static const Color chartBlue = Color(0xFF0EA5E9);
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartPink = Color(0xFFEC4899);
  static const Color chartYellow = Color(0xFFEAB308);
  static const Color chartPurple = Color(0xFF8B5CF6);

  // Legacy aliases for backward compatibility
  static const Color primaryPurple = primaryGreen;
  static const Color primaryPurpleLight = primaryGreenLight;
  static const Color primaryPurpleDark = primaryGreenDark;
  static const Color primaryBlue = accentBlue; // For layout compatibility
  static const Color backgroundLight = backgroundDark;
  static const Color surfaceWhite = surfaceDark;
  static const Color borderLight = borderDark;
  static const Color borderLighter = borderDarkLight;

  static ThemeData get lightTheme => darkTheme; // Use dark theme as default

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryGreenLight,
        tertiary: accentBlue,
        surface: surfaceDark,
        error: accentRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
        outline: borderDark,
        outlineVariant: borderDarkLight,
        primaryContainer: primaryGreen.withValues(alpha: 0.15),
        onPrimaryContainer: primaryGreen,
      ),
      scaffoldBackgroundColor: backgroundDark,

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PingAR',
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Typography with PingAR font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'PingAR',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryGreen.withValues(alpha: 0.15),
        labelStyle: const TextStyle(
          fontFamily: 'PingAR',
          color: primaryGreen,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // DataTable theme
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(surfaceDarkLighter),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return surfaceDarkHover;
          }
          return surfaceDark;
        }),
        dividerThickness: 1,
        headingTextStyle: const TextStyle(
          fontFamily: 'PingAR',
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: 'PingAR',
          color: textPrimary,
        ),
      ),
    );
  }
}
