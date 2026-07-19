import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import '../../domain/entities/project_entity.dart';

class ProjectListItem extends StatefulWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDragHandle;
  final int dragIndex;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    this.showDragHandle = false,
    this.dragIndex = 0,
  });

  @override
  State<ProjectListItem> createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<ProjectListItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _isHovered = true);
    _ctrl.forward();
  }

  void _onExit(_) {
    setState(() => _isHovered = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) => Container(
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                p.color.withValues(alpha: 0.06 + 0.06 * _anim.value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35],
            ),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.07),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: p.color.withValues(alpha: 0.1 * _anim.value),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: child,
        ),
        child: Row(
          children: [
            // Drag handle (reorder mode)
            if (widget.showDragHandle)
              ReorderableDragStartListener(
                index: widget.dragIndex,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 0.45 : 0.14,
                    duration: const Duration(milliseconds: 180),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.drag_indicator_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            // Left color bar
            _ColorBar(color: widget.project.color, isHovered: _isHovered),
            // Thumbnail
            _Thumbnail(project: widget.project, isHovered: _isHovered),
            const SizedBox(width: 20),
            // Info
            Expanded(child: _buildInfo(p)),
            // Stats
            _buildStats(p),
            // Actions
            AnimatedOpacity(
              opacity: _isHovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: _buildActions(),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(Project p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          p.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _isHovered ? AppColors.primary : Colors.white,
            letterSpacing: 0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          p.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.38),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 4,
          children: [
            ...p.tech.take(4).map(
                  (t) => _TechChip(label: t, color: p.color),
                ),
            if (p.tech.length > 4)
              _TechChip(label: '+${p.tech.length - 4}', color: Colors.white24),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(Project p) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (p.downloads.isNotEmpty)
            _StatRow(
              icon: Icons.download_rounded,
              label: p.downloads,
              color: AppColors.primary,
            ),
          if (p.androidStoreUrl != null || p.iosStoreUrl != null) ...[
            const SizedBox(height: 6),
            const _StatRow(
              icon: Icons.rocket_launch_rounded,
              label: 'Live',
              color: Color(0xFF4ADE80),
            ),
          ],
          if (p.galleryImages != null && p.galleryImages!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _StatRow(
              icon: Icons.photo_library_rounded,
              label: '${p.galleryImages!.length} imgs',
              color: Colors.white38,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionBtn(
          icon: Icons.edit_rounded,
          color: AppColors.primary,
          tooltip: 'Edit',
          onPressed: widget.onEdit,
        ),
        const SizedBox(width: 8),
        _ActionBtn(
          icon: Icons.delete_rounded,
          color: Colors.redAccent,
          tooltip: 'Delete',
          onPressed: widget.onDelete,
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ColorBar extends StatelessWidget {
  final Color color;
  final bool isHovered;

  const _ColorBar({required this.color, required this.isHovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 4,
      height: isHovered ? 60 : 36,
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isHovered ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.65),
                  blurRadius: 10,
                )
              ]
            : [],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Project project;
  final bool isHovered;

  const _Thumbnail({required this.project, required this.isHovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 120,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: project.color.withValues(alpha: 0.08),
        border: Border.all(
          color: project.color.withValues(alpha: isHovered ? 0.5 : 0.15),
          width: isHovered ? 1.5 : 1,
        ),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: project.color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
        image: project.imageUrl != null && project.imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(project.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: project.imageUrl == null || project.imageUrl!.isEmpty
          ? Center(
              child: Icon(
                Icons.rocket_launch_rounded,
                color: project.color.withValues(alpha: 0.3),
                size: 26,
              ),
            )
          : null,
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TechChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.85),
          letterSpacing: 0.4,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _hovered ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.color.withValues(alpha: _hovered ? 0.5 : 0.15),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(widget.icon, size: 16),
            color: widget.color,
            onPressed: widget.onPressed,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(34, 34),
            ),
          ),
        ),
      ),
    );
  }
}
