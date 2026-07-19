import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/projects_cubit.dart';
import '../bloc/projects_state.dart';
import '../../domain/entities/project_entity.dart';
import '../widgets/project_list_item.dart';
import '../widgets/project_grid_item.dart';
import 'project_form_view.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  bool _isGridView = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final state = context.read<ProjectsCubit>().state;
      if (state is ProjectsInitial || state is ProjectsError) {
        context.read<ProjectsCubit>().fetchProjects();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> _filter(List<Project> all) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.tech.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void _showProjectForm([Project? project]) {
    final cubit = context.read<ProjectsCubit>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => Align(
        alignment: Alignment.center,
        child: BlocProvider.value(
          value: cubit,
          child: Material(
            color: Colors.transparent,
            child: ProjectFormView(project: project),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14 * animation.value,
            sigmaY: 14 * animation.value,
          ),
          child: FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(scale: curved, child: child),
          ),
        );
      },
    );
  }

  void _confirmDelete(Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Project?',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white60, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"${project.title}"',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: '? This cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              final isDeleting = state is ProjectsLoading;
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isDeleting
                    ? null
                    : () {
                        context
                            .read<ProjectsCubit>()
                            .deleteProject(project.id);
                        Navigator.pop(ctx);
                      },
                icon: isDeleting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_rounded, size: 16),
                label: Text(isDeleting ? 'Deleting…' : 'Delete'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final pState = context.read<ProjectsCubit>().state;
          if (pState is ProjectsInitial || pState is ProjectsError) {
            context.read<ProjectsCubit>().fetchProjects();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsAndSearch(),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 46,
          height: 46,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.rocket_launch_rounded,
              color: AppColors.primary, size: 22),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Manage portfolio projects, case studies & apps',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
        // View toggle
        _ViewToggle(
          isGrid: _isGridView,
          onToggle: (isGrid) => setState(() => _isGridView = isGrid),
        ),
        const SizedBox(width: 14),
        _AddButton(onPressed: _showProjectForm),
      ],
    );
  }

  // ── Stats + Search row ─────────────────────────────────────────────────────

  Widget _buildStatsAndSearch() {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        final projects =
            state is ProjectsLoaded ? state.projects : <Project>[];
        final liveCount = projects
            .where((p) =>
                p.androidStoreUrl != null || p.iosStoreUrl != null)
            .length;

        return Row(
          children: [
            // Stats chips
            if (projects.isNotEmpty) ...[
              _StatChip(
                icon: Icons.folder_copy_rounded,
                label: '${projects.length} Projects',
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              if (liveCount > 0) ...[
                _StatChip(
                  icon: Icons.rocket_launch_rounded,
                  label: '$liveCount Live',
                  color: const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 10),
              ],
            ],
            // Search bar fills remaining space
            Expanded(child: _buildSearchBar()),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search projects…',
        hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Colors.white30, size: 19),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 17, color: Colors.white30),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading) return _buildShimmer();
        if (state is ProjectsError) return _buildError(state.message);
        if (state is ProjectsLoaded) {
          final filtered = _filter(state.projects);
          if (state.projects.isEmpty) return _buildEmpty(hasSearch: false);
          if (filtered.isEmpty) return _buildEmpty(hasSearch: true);
          return _buildProjectsView(filtered);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProjectsView(List<Project> projects) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: _isGridView
          ? _GridView(
              key: const ValueKey('grid'),
              projects: projects,
              onEdit: _showProjectForm,
              onDelete: _confirmDelete,
            )
          : _ListView(
              key: const ValueKey('list'),
              projects: projects,
              onEdit: _showProjectForm,
              onDelete: _confirmDelete,
            ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.04),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: _isGridView
          ? GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.82,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            )
          : ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) => Container(
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────

  Widget _buildEmpty({required bool hasSearch}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.rocket_launch_rounded,
              size: 38,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasSearch
                ? 'No results for "$_searchQuery"'
                : 'No projects yet',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try a different title, description, or technology.'
                : 'Start building your portfolio. Add your first project.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showProjectForm,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.redAccent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 34, color: Colors.redAccent),
          ),
          const SizedBox(height: 20),
          const Text(
            'Failed to load projects',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<ProjectsCubit>().fetchProjects(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid / List wrappers ──────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final List<Project> projects;
  final void Function([Project?]) onEdit;
  final void Function(Project) onDelete;

  const _GridView({
    super.key,
    required this.projects,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 2;
        if (constraints.maxWidth > 1300) {
          columns = 4;
        } else if (constraints.maxWidth > 900) {
          columns = 3;
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.80,
          ),
          itemCount: projects.length,
          itemBuilder: (context, i) {
            final p = projects[i];
            return ProjectGridItem(
              key: ValueKey(p.id),
              project: p,
              onEdit: () => onEdit(p),
              onDelete: () => onDelete(p),
            );
          },
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List<Project> projects;
  final void Function([Project?]) onEdit;
  final void Function(Project) onDelete;

  const _ListView({
    super.key,
    required this.projects,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        elevation: 0,
        child: child,
      ),
      onReorder: (oldIndex, newIndex) {
        context
            .read<ProjectsCubit>()
            .reorderProjects(projects, oldIndex, newIndex);
      },
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
        return Padding(
          key: ValueKey(p.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: ProjectListItem(
            project: p,
            onEdit: () => onEdit(p),
            onDelete: () => onDelete(p),
            showDragHandle: true,
            dragIndex: i,
          ),
        );
      },
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final void Function(bool) onToggle;

  const _ViewToggle({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.list_rounded,
            active: !isGrid,
            tooltip: 'List view',
            onPressed: () => onToggle(false),
          ),
          const SizedBox(width: 2),
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            active: isGrid,
            tooltip: 'Grid view',
            onPressed: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToggleBtn({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: active
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: IconButton(
          icon: Icon(icon, size: 18),
          color: active ? AppColors.primary : Colors.white30,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Project'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
