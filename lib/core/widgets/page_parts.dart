import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_button.dart';
import 'pressable.dart';

/// Page title block used at the top of every content page.
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.5,
            height: 1.4,
          ),
        ),
      ],
    );
    final actionRow = [
      for (final (i, a) in actions.indexed) ...[
        if (i > 0) const SizedBox(width: 10),
        a,
      ],
    ];

    // On a phone the actions go under the title instead of squeezing it.
    if (MediaQuery.sizeOf(context).width < 700) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: actionRow),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        ...actionRow,
      ],
    );
  }
}

/// Small count chip: "12 projects". Numbers are set in Geist Mono.
class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? count;
  final Color color;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          if (count != null) ...[
            Text(count!,
                style: AppFonts.monoStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search input on a white surface with a hairline border.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 18),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textTertiary),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Segmented grid/list switch.
class ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onToggle;

  const ViewToggle({super.key, required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            icon: Icons.view_agenda_outlined,
            tooltip: 'List view',
            active: !isGrid,
            onTap: () => onToggle(false),
          ),
          _Segment(
            icon: Icons.grid_view_rounded,
            tooltip: 'Grid view',
            active: isGrid,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        semanticLabel: tooltip,
        builder: (context, hovered) => AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.ease,
          width: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x1A16171A),
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 17,
            color: active || hovered ? AppColors.ink : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Centered empty / error message with an optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool isError;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = isError ? AppColors.danger : AppColors.primary;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Icon(icon, size: 24, color: tint),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel!,
                icon: actionIcon,
                variant: isError
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.primary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// White card with hairline border and soft shadow; lifts slightly on hover.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    Widget card(bool hovered) => AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.ease,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: hovered ? AppColors.borderStrong : AppColors.border),
            boxShadow: hovered ? AppShadows.raised : AppShadows.card,
          ),
          child: child,
        );
    if (onTap == null) return card(false);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.99,
      focusRadius: radius,
      builder: (context, hovered) => card(hovered),
    );
  }
}

/// Small white icon button with a hairline border (edit, delete, open).
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool destructive;
  final double size;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: tooltip,
        builder: (context, hovered) {
          final fg = destructive
              ? (hovered ? AppColors.danger : AppColors.textTertiary)
              : (hovered ? AppColors.ink : AppColors.textSecondary);
          final bg = hovered
              ? (destructive ? const Color(0xFFFEF3F2) : AppColors.background)
              : AppColors.surface;
          return AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.ease,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hovered && destructive
                    ? AppColors.danger.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Icon(icon, size: size * 0.5, color: fg),
          );
        },
      ),
    );
  }
}

/// Rebuilds with whether a mouse pointer is over the child. Touch devices
/// never report hover, so nothing depends on it for function.
class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  const HoverBuilder({super.key, required this.builder});

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(context, _hovered),
    );
  }
}

/// The padding around a page's content: roomy on a desktop, tighter on a
/// tablet, and phone-sized on a phone, so content keeps most of the width.
EdgeInsets pagePadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 700) return const EdgeInsets.fromLTRB(16, 20, 16, 16);
  if (width < 1000) return const EdgeInsets.fromLTRB(24, 28, 24, 20);
  return const EdgeInsets.fromLTRB(40, 36, 40, 24);
}

/// Shows a confirm dialog for a destructive action. Returns true when the
/// owner confirms.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String itemName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5),
          children: [
            const TextSpan(text: 'Delete '),
            TextSpan(
              text: '"$itemName"',
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: '? This cannot be undone.'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        AppButton(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Dialog route with a short fade + scale-up (0.96 -> 1), strong ease-out.
Future<T?> showAppDialog<T>(BuildContext context, WidgetBuilder builder) {
  final reduced = AppMotion.reduced(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.ink.withValues(alpha: 0.32),
    transitionDuration: reduced ? Duration.zero : AppMotion.slow,
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.center,
      child: Material(color: Colors.transparent, child: builder(ctx)),
    ),
    transitionBuilder: (ctx, animation, _, child) {
      final curved = CurvedAnimation(
          parent: animation, curve: AppMotion.ease, reverseCurve: Curves.easeIn);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
