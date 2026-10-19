import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';
import '../../domain/entities/project_entity.dart';
import 'project_badges.dart';

/// Project card for the grid view: a white card whose only colour is the
/// project's own (a thin top stripe and the dot by the title). Actions are
/// always visible, so they work on touch screens too.
class ProjectGridItem extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenCaseStudy;

  const ProjectGridItem({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.onOpenCaseStudy,
  });

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Pressable(
      onTap: onEdit,
      pressedScale: 0.99,
      semanticLabel: 'Edit ${p.title}',
      builder: (context, hovered) => AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.medium),
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(
            0, hovered && !AppMotion.reduced(context) ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hovered ? AppColors.borderStrong : AppColors.border),
          boxShadow: hovered ? AppShadows.raised : AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 3, color: p.color),
              Expanded(flex: 10, child: _Cover(project: p)),
              Expanded(flex: 11, child: _Info(project: p)),
              const Divider(height: 1),
              _Actions(
                onEdit: onEdit,
                onDelete: onDelete,
                onOpenCaseStudy: onOpenCaseStudy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final Project project;
  const _Cover({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    final hasCover = p.imageUrl != null && p.imageUrl!.isNotEmpty;
    final isLive = p.androidStoreUrl != null || p.iosStoreUrl != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCover)
          Image.network(
            p.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (ctx, e, s) => _Placeholder(project: p),
          )
        else
          _Placeholder(project: p),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (p.featured) const FeaturedBadge(),
              if (isLive) const LiveBadge(),
            ],
          ),
        ),
        if (p.downloads.isNotEmpty)
          Positioned(
            bottom: 10,
            left: 10,
            child: DownloadsBadge(label: p.downloads),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Project project;
  const _Placeholder({required this.project});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(child: ProjectLogo(project: project, size: 52)),
    );
  }
}

class _Info extends StatelessWidget {
  final Project project;
  const _Info({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    final highlight = p.highlight?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ColorDot(color: p.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            highlight.isNotEmpty ? highlight : p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: highlight.isNotEmpty
                  ? AppColors.ink
                  : AppColors.textSecondary,
              fontWeight:
                  highlight.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
              height: 1.45,
            ),
          ),
          const Spacer(),
          TechChips(tech: p.tech, max: 3),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenCaseStudy;

  const _Actions({
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCaseStudy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: CaseStudyLink(onTap: onOpenCaseStudy),
          ),
          IconActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
          const SizedBox(width: 6),
          IconActionButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete',
            destructive: true,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
