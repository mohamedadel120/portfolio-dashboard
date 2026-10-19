import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'pressable.dart';

enum AppButtonVariant {
  /// Teal-filled pill, white text.
  primary,

  /// Ink-filled pill, white text.
  ink,

  /// White pill with a hairline border.
  secondary,

  /// Text-only, for low-emphasis actions.
  ghost,

  /// White pill with danger text, for destructive actions.
  danger,
}

/// Pill button used across the dashboard. Presses scale to 0.97; hover
/// darkens the fill slightly (mouse pointers only).
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final bool compact;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Pressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      builder: (context, hovered) {
        final (bg, fg, border) = _colors(hovered);
        final content = Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else if (icon != null)
              Icon(icon, size: compact ? 16 : 18, color: fg),
            if (isLoading || icon != null) const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        );
        return AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: enabled || isLoading ? 1 : 0.45,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.ease,
            height: compact ? 36 : 44,
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
            decoration: ShapeDecoration(
              color: bg,
              shape: StadiumBorder(
                side: border == null
                    ? BorderSide.none
                    : BorderSide(color: border),
              ),
              shadows: variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.ink
                  ? const [
                      BoxShadow(
                        color: Color(0x1F16171A),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(widthFactor: 1, child: content),
          ),
        );
      },
    );
  }

  (Color, Color, Color?) _colors(bool hovered) {
    switch (variant) {
      case AppButtonVariant.primary:
        return (
          hovered ? AppColors.secondary : AppColors.primary,
          AppColors.onPrimary,
          null,
        );
      case AppButtonVariant.ink:
        return (
          hovered ? const Color(0xFF2A2B30) : AppColors.ink,
          Colors.white,
          null,
        );
      case AppButtonVariant.secondary:
        return (
          hovered ? AppColors.background : AppColors.surface,
          AppColors.ink,
          AppColors.borderStrong,
        );
      case AppButtonVariant.ghost:
        return (
          hovered ? AppColors.ink.withValues(alpha: 0.05) : Colors.transparent,
          AppColors.textSecondary,
          null,
        );
      case AppButtonVariant.danger:
        return (
          hovered ? const Color(0xFFFEF3F2) : AppColors.surface,
          AppColors.danger,
          hovered
              ? AppColors.danger.withValues(alpha: 0.4)
              : AppColors.borderStrong,
        );
    }
  }
}
