import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import '../../domain/entities/project_entity.dart';
import 'project_badges.dart';

/// Project row for the list (reorder) view. The project's own colour shows
/// as a thin stripe on the left edge and as the dot by the title.
class ProjectListItem extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenCaseStudy;
  final bool showDragHandle;
  final int dragIndex;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.onOpenCaseStudy,
    this.showDragHandle = false,
    this.dragIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = project;
    final isLive = p.androidStoreUrl != null || p.iosStoreUrl != null;
    final highlight = p.highlight?.trim() ?? '';

    return SurfaceCard(
      padding: EdgeInsets.zero,
      onTap: onEdit,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: p.color,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(15)),
              ),
            ),
            if (showDragHandle)
              ReorderableDragStartListener(
                index: dragIndex,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.drag_indicator_rounded,
                        color: AppColors.textTertiary, size: 18),
                  ),
                ),
              )
            else
              const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: ProjectLogo(project: p, size: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        ColorDot(color: p.color),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (p.featured) ...[
                          const SizedBox(width: 8),
                          const FeaturedBadge(),
                        ],
                        if (isLive) ...[
                          const SizedBox(width: 6),
                          const LiveBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      highlight.isNotEmpty ? highlight : p.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TechChips(tech: p.tech, max: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (p.downloads.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    p.downloads,
                    style: AppFonts.monoStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              ),
            Center(child: CaseStudyLink(onTap: onOpenCaseStudy)),
            const SizedBox(width: 8),
            Center(
              child: IconActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: IconActionButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Delete',
                destructive: true,
                onPressed: onDelete,
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
