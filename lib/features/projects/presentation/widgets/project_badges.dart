import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';
import '../../domain/entities/project_entity.dart';

/// Small white pill used for badges on project cards.
class _Pill extends StatelessWidget {
  final Widget leading;
  final String label;
  final Color color;
  final bool mono;

  const _Pill({
    required this.leading,
    required this.label,
    this.color = AppColors.ink,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1416171A), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 5),
          Text(
            label,
            style: mono
                ? AppFonts.monoStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: color)
                : TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) => const _Pill(
        leading: Icon(Icons.star_rounded, size: 13, color: AppColors.primary),
        label: 'Featured',
        color: AppColors.primary,
      );
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) => _Pill(
        leading: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle),
        ),
        label: 'Live',
        color: AppColors.success,
      );
}

class DownloadsBadge extends StatelessWidget {
  final String label;
  const DownloadsBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) => _Pill(
        leading: const Icon(Icons.download_rounded,
            size: 12, color: AppColors.textSecondary),
        label: label,
        mono: true,
      );
}

/// The project's own colour as a small dot.
class ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  const ColorDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
      ),
    );
  }
}

/// The project's logo, or its initial on a tint of the project colour.
class ProjectLogo extends StatelessWidget {
  final Project project;
  final double size;
  const ProjectLogo({super.key, required this.project, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final p = project;
    final radius = BorderRadius.circular(size * 0.26);
    final hasLogo = p.logoUrl != null && p.logoUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: hasLogo
            ? Image.network(
                p.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => _initial(p),
              )
            : _initial(p),
      ),
    );
  }

  Widget _initial(Project p) => ColoredBox(
        color: p.color.withValues(alpha: 0.12),
        child: Center(
          child: Text(
            p.title.isNotEmpty ? p.title[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.4,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
}

/// Neutral technology tags, set in Geist Mono.
class TechChips extends StatelessWidget {
  final List<String> tech;
  final int max;
  const TechChips({super.key, required this.tech, this.max = 3});

  @override
  Widget build(BuildContext context) {
    final visible = tech.take(max).toList();
    final overflow = tech.length - visible.length;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final t in visible) TechChip(label: t),
        if (overflow > 0) TechChip(label: '+$overflow'),
      ],
    );
  }
}

class TechChip extends StatelessWidget {
  final String label;
  const TechChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppFonts.monoStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}

/// "Open case study" text action with an outward arrow; opens a new tab.
class CaseStudyLink extends StatelessWidget {
  final VoidCallback? onTap;
  const CaseStudyLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'Opens the case study page on the site in a new tab',
        child: Pressable(
          onTap: onTap,
          semanticLabel: 'Open case study',
          builder: (context, hovered) => AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.ease,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: hovered ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open case study',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_outward_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
