import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Light, product-first theme matching the portfolio site ("direction c").
/// Geist for everything readable; Geist Mono only where a widget asks for it
/// (numbers, ids, tags) via [AppFonts.monoStyle].
class AppTheme {
  static const _radiusCard = 16.0;
  static const _radiusInput = 12.0;

  static TextTheme _textTheme(TextTheme base) {
    TextStyle? heading(TextStyle? s, {double tracking = -0.2}) => s?.copyWith(
          fontFamily: AppFonts.sans,
          fontWeight: FontWeight.w600,
          letterSpacing: tracking,
          color: AppColors.ink,
        );

    final body = base.apply(
      fontFamily: AppFonts.sans,
      bodyColor: AppColors.textSecondary,
      displayColor: AppColors.ink,
    );

    return body.copyWith(
      displayLarge: heading(body.displayLarge, tracking: -1.0),
      displayMedium: heading(body.displayMedium, tracking: -0.8),
      displaySmall: heading(body.displaySmall, tracking: -0.6),
      headlineLarge: heading(body.headlineLarge, tracking: -0.6),
      headlineMedium: heading(body.headlineMedium, tracking: -0.5),
      headlineSmall: heading(body.headlineSmall, tracking: -0.4),
      titleLarge: heading(body.titleLarge, tracking: -0.3),
      titleMedium: heading(body.titleMedium),
      titleSmall: heading(body.titleSmall, tracking: -0.1),
      bodyLarge: body.bodyLarge?.copyWith(color: AppColors.ink),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusInput),
        borderSide: BorderSide(color: color, width: width),
      );

  static final ThemeData lightTheme = _build();

  /// Kept so older references keep compiling; the dashboard is light-only.
  static ThemeData get darkTheme => lightTheme;

  static ThemeData _build() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    const pill = StadiumBorder();
    const buttonText = TextStyle(
      fontFamily: AppFonts.sans,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.1,
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: _textTheme(base.textTheme),
      primaryTextTheme: _textTheme(base.primaryTextTheme),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceContainerLowest: AppColors.surface,
        surfaceContainerLow: AppColors.surface,
        surfaceContainer: AppColors.surface,
        surfaceContainerHigh: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceLight,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.border,
        error: AppColors.danger,
        onError: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      dividerColor: AppColors.border,
      dividerTheme:
          const DividerThemeData(color: AppColors.border, thickness: 1),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      hoverColor: AppColors.ink.withValues(alpha: 0.04),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      focusColor: AppColors.primary.withValues(alpha: 0.12),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.18),
        selectionHandleColor: AppColors.primary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: AppColors.ink.withValues(alpha: 0.32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 14,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w500),
        hintStyle:
            const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        helperStyle: const TextStyle(
            color: AppColors.textTertiary, fontSize: 12, height: 1.4),
        helperMaxLines: 3,
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        border: _inputBorder(AppColors.borderStrong),
        enabledBorder: _inputBorder(AppColors.borderStrong),
        disabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, 1.5),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: pill,
          padding: buttonPadding,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          shape: pill,
          padding: buttonPadding,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.borderStrong),
          shape: pill,
          padding: buttonPadding,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: pill,
          padding: buttonPadding,
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceLight,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.borderStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight,
        circularTrackColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(
            fontFamily: AppFonts.sans, color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
            fontFamily: AppFonts.sans, color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.ink.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle: const TextStyle(
            fontFamily: AppFonts.sans, color: AppColors.ink, fontSize: 14),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
            fontFamily: AppFonts.sans, color: AppColors.ink, fontSize: 14),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
            AppColors.ink.withValues(alpha: 0.18)),
        radius: const Radius.circular(8),
      ),
    );
  }
}
