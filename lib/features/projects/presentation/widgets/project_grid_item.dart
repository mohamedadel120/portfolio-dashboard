import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import '../../domain/entities/project_entity.dart';

class ProjectGridItem extends StatefulWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectGridItem({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
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
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            // Lift on hover
            transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
            child: Container(
              // Gradient border — outer container provides the border paint
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    p.color.withValues(alpha: _isHovered ? 0.55 : 0.22),
                    AppColors.primary.withValues(
                      alpha: _isHovered ? 0.25 : 0.06,
                    ),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  // Color glow
                  BoxShadow(
                    color: p.color.withValues(alpha: 0.22 * _anim.value),
                    blurRadius: 48,
                    spreadRadius: -4,
                    offset: const Offset(0, 16),
                  ),
                  // Cyan fringe
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.10 * _anim.value,
                    ),
                    blurRadius: 28,
                    spreadRadius: -10,
                  ),
                  // Base depth shadow (always present, stronger on hover)
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.55 : 0.25,
                    ),
                    blurRadius: _isHovered ? 36 : 16,
                    spreadRadius: -6,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1), // border thickness
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                widget.project.color.withValues(alpha: 0.10),
                AppColors.background.withValues(alpha: 0.95),
                AppColors.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 11, child: _buildImageArea(widget.project)),
              Expanded(flex: 9, child: _buildInfoSection(widget.project)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image area ─────────────────────────────────────────────────────────────

  Widget _buildImageArea(Project p) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        // Cover image / placeholder
        _buildCover(p),
        // Bottom gradient fade
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.35, 1.0],
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
        ),
        // Downloads badge – top left
        if (p.downloads.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: _GlassBadge(
              icon: Icons.download_rounded,
              label: p.downloads,
              color: AppColors.primary,
            ),
          ),
        // Live badge – top right
        if (p.androidStoreUrl != null || p.iosStoreUrl != null)
          const Positioned(top: 12, right: 12, child: _LiveBadge()),
        // Gallery badge (if no live)
        if (p.androidStoreUrl == null &&
            p.iosStoreUrl == null &&
            (p.galleryImages?.isNotEmpty ?? false))
          Positioned(
            top: 12,
            right: 12,
            child: _GlassBadge(
              icon: Icons.photo_library_rounded,
              label: '${p.galleryImages!.length}',
              color: Colors.white54,
            ),
          ),
        // App logo / initials badge — bottom left, overlapping the boundary
        Positioned(bottom: -18, left: 14, child: _LogoBadge(project: p)),
        // Hover action overlay
        AnimatedOpacity(
          opacity: _isHovered ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            color: Colors.black.withValues(alpha: 0.58),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HoverAction(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: AppColors.primary,
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: 20),
                _HoverAction(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  color: Colors.redAccent,
                  onTap: widget.onDelete,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCover(Project p) {
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      return Image.network(
        p.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _buildPlaceholder(p),
      );
    }
    return _buildPlaceholder(p);
  }

  Widget _buildPlaceholder(Project p) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.color.withValues(alpha: 0.22),
            p.color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPatternPainter(p.color)),
          ),
          Center(
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 40,
              color: p.color.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info section ───────────────────────────────────────────────────────────

  Widget _buildInfoSection(Project p) {
    return Padding(
      // Extra top padding to make room for the logo badge overlap
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _isHovered ? AppColors.primary : Colors.white,
              letterSpacing: 0.1,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            p.description,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.36),
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 14),
          _buildTechRow(p),
        ],
      ),
    );
  }

  Widget _buildTechRow(Project p) {
    final visible = p.tech.take(3).toList();
    final overflow = p.tech.length - visible.length;
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        ...visible.map((t) => _TechChip(label: t, color: p.color)),
        if (overflow > 0) _TechChip(label: '+$overflow', color: Colors.white24),
      ],
    );
  }
}

// ── Logo badge ────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  final Project project;
  const _LogoBadge({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: project.color.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: project.color.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
          const BoxShadow(color: Colors.black, blurRadius: 6, spreadRadius: -2),
        ],
      ),
      child: ClipOval(
        child: project.logoUrl != null && project.logoUrl!.isNotEmpty
            ? Image.network(
                project.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => _initials(project),
              )
            : _initials(project),
      ),
    );
  }

  Widget _initials(Project p) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.color.withValues(alpha: 0.9),
            p.color.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Text(
          p.title.isNotEmpty ? p.title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ── Glass badge ───────────────────────────────────────────────────────────────

class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GlassBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live badge ────────────────────────────────────────────────────────────────

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Live',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4ADE80),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tech chip ─────────────────────────────────────────────────────────────────

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
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

// ── Hover action button ───────────────────────────────────────────────────────

class _HoverAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HoverAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverAction> createState() => _HoverActionState();
}

class _HoverActionState extends State<_HoverAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _hovered ? 0.28 : 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.color.withValues(alpha: _hovered ? 0.65 : 0.3),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 22),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Grid pattern painter for placeholder ──────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  final Color color;
  _GridPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter old) => old.color != color;
}
