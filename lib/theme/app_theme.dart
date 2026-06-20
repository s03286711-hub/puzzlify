import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Background palette ──────────────────────────────────────────
  static const Color bgDark   = Color(0xFF090E1A);
  static const Color bgMedium = Color(0xFF12172A);
  static const Color bgCard   = Color(0xFF1C2340);
  static const Color bgGrid   = Color(0xFF141B33);
  static const Color gridLine = Color(0xFF222B4A);

  // ── Brand accent ────────────────────────────────────────────────
  static const Color accent      = Color(0xFF7C6FF7);
  static const Color accentLight = Color(0xFFB0AAFF);
  static const Color accentDark  = Color(0xFF4A3FCC);

  // ── Text ────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEEEEFF);
  static const Color textSecondary = Color(0xFF8890BB);

  // ── UI chrome ───────────────────────────────────────────────────
  static const Color starColor = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF3A4060);

  // ── 10 vibrant game dot colours ─────────────────────────────────
  static const List<Color> dotColors = [
    Color(0xFFFF4F5E), // 0  Red
    Color(0xFF4FAAFF), // 1  Blue
    Color(0xFF4FDD6F), // 2  Green
    Color(0xFFFFD044), // 3  Yellow
    Color(0xFFCC55FF), // 4  Purple
    Color(0xFFFF8844), // 5  Orange
    Color(0xFFFF44BB), // 6  Pink
    Color(0xFF44DDCC), // 7  Cyan
    Color(0xFFFFFFFF), // 8  White
    Color(0xFFFF6644), // 9  Coral
  ];

  // ── Typography helpers ───────────────────────────────────────────
  static TextStyle heading(double size, {Color? color, double? letterSpacing}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? textPrimary,
        letterSpacing: letterSpacing ?? -0.5,
      );

  static TextStyle body(double size,
          {Color? color, FontWeight? weight, double? letterSpacing}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textPrimary,
        letterSpacing: letterSpacing,
      );

  // ── MaterialApp theme ───────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: bgCard,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      );
}
