import 'package:flutter/material.dart';

/// Custom font family constants for the application
class AppFonts {
  AppFonts._();

  /// Primary Arabic font family: PingAR+LT
  static const String pingar = 'PingAR';

  /// Font weights mapping
  static const FontWeight hairline = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500; // Falls back to regular
  static const FontWeight semiBold = FontWeight.w600; // Falls back to bold
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  /// Get TextStyle with PingAR font
  static TextStyle pingingStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: pingar,
      fontSize: fontSize,
      fontWeight: fontWeight ?? regular,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Predefined text styles using PingAR
  static TextStyle get displayLarge =>
      pingingStyle(fontSize: 57, fontWeight: bold, height: 1.12);

  static TextStyle get displayMedium =>
      pingingStyle(fontSize: 45, fontWeight: bold, height: 1.16);

  static TextStyle get displaySmall =>
      pingingStyle(fontSize: 36, fontWeight: semiBold, height: 1.22);

  static TextStyle get headlineLarge =>
      pingingStyle(fontSize: 32, fontWeight: bold, height: 1.25);

  static TextStyle get headlineMedium =>
      pingingStyle(fontSize: 28, fontWeight: semiBold, height: 1.29);

  static TextStyle get headlineSmall =>
      pingingStyle(fontSize: 24, fontWeight: semiBold, height: 1.33);

  static TextStyle get titleLarge =>
      pingingStyle(fontSize: 22, fontWeight: semiBold, height: 1.27);

  static TextStyle get titleMedium => pingingStyle(
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle get titleSmall => pingingStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => pingingStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => pingingStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static TextStyle get bodySmall => pingingStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static TextStyle get labelLarge => pingingStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => pingingStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => pingingStyle(
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
  );
}
