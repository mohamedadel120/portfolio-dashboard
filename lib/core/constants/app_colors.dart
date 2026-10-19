import 'package:flutter/material.dart';

/// Light, product-first palette shared with the portfolio site
/// ("direction c"): warm off-white ground, white surfaces, ink text and a
/// single deep-teal brand colour. Each project's own colour is the only
/// other accent, and it is used sparingly (dots, stripes, chips).
class AppColors {
  // Brand
  static const Color primary = Color(0xFF155E75); // deep teal
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// The light direction has a single brand colour; "secondary" is the
  /// darker teal, used for pressed/hover states of teal fills.
  static const Color secondary = Color(0xFF0F4A5C);

  /// Teal at low alpha, for selected/active backgrounds.
  static const Color primarySoft = Color(0x14155E75); // ~8%

  // Ground and surfaces
  static const Color background = Color(0xFFF6F5F1); // warm off-white
  static const Color surface = Color(0xFFFFFFFF); // cards, dialogs
  static const Color surfaceLight = Color(0xFFEEECE6); // subtle fill
  static const Color subtle = surfaceLight;

  // Ink
  static const Color ink = Color(0xFF16171A);
  static const Color textPrimary = ink;

  /// Ink at ~72%.
  static const Color textSecondary = Color(0xB816171A);

  /// Ink at ~62%. Still >= 4.5:1 on white and on the off-white ground.
  static const Color textTertiary = Color(0x9E16171A);

  // Hairlines
  static const Color border = Color(0x1A16171A); // ink ~10%
  static const Color borderStrong = Color(0x2E16171A); // ink ~18%

  // Status colours (AA on white)
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFB42318);
  static const Color warning = Color(0xFFB54708);

  // Legacy names from the dark theme, mapped onto the new palette.
  static const Color accentCyan = primary;
  static const Color accentPurple = secondary;
}

/// Soft, real shadows. No coloured glows.
class AppShadows {
  /// 0 1px 2px rgba(22,23,26,.06), 0 8px 24px -12px rgba(22,23,26,.18)
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F16171A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x2E16171A),
      blurRadius: 24,
      spreadRadius: -12,
      offset: Offset(0, 8),
    ),
  ];

  /// Slightly lifted: hovered cards, dialogs, popovers.
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x1416171A), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x3816171A),
      blurRadius: 32,
      spreadRadius: -12,
      offset: Offset(0, 14),
    ),
  ];
}

/// Motion tokens: short durations with a strong ease-out.
class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);

  /// cubic-bezier(0.23, 1, 0.32, 1)
  static const Curve ease = Cubic(0.23, 1, 0.32, 1);

  /// True when the platform asks for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Returns [d], or zero when reduced motion is requested.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}

/// Font families (bundled in assets/fonts, SIL OFL).
class AppFonts {
  static const String sans = 'Geist';
  static const String mono = 'GeistMono';

  /// Geist Mono, for numbers, ids and small tags only.
  static TextStyle monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: mono,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
