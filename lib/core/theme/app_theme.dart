import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _buildTextTheme(ThemeData baseTheme) {
    final baseTextTheme = baseTheme.textTheme;

    // Body Text & Explanations -> JetBrains Mono (Regular), White70
    final bodyTheme = GoogleFonts.jetBrainsMonoTextTheme(baseTextTheme).apply(
      bodyColor: Colors.white70,
      displayColor: Colors.white,
    );

    // Main Headings -> IBM Plex Mono (Bold), White/Cyan
    final headingTheme = GoogleFonts.ibmPlexMonoTextTheme(baseTextTheme);

    return bodyTheme.copyWith(
      displayLarge: headingTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: headingTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: headingTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: headingTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: headingTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: headingTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: headingTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: headingTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      titleSmall: headingTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Dark Theme (Default/Coding Mode)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _buildTextTheme(ThemeData.dark()),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: Colors.black, // Text on white primary should be black
      onSecondary: Colors.black,
      onSurface: Colors.white,
      surfaceContainerHighest: AppColors.surfaceLight,
    ),
  );
}
