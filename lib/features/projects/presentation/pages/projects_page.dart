import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/projects_cubit.dart';
import '../bloc/projects_state.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/project_slug.dart';
import '../widgets/project_list_item.dart';
import '../widgets/project_grid_item.dart';
import 'project_form_view.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';

/// Case-study URL for every project, keyed by id, computed exactly like the
/// site does (unique slugs, featured projects first).
Map<String, String> caseStudyUrls(List<Project> projects) {
  final slugs = ProjectSlug.unique([
    for (final p in projects)
      (title: p.title, slug: p.slug, featured: p.featured, sortOrder: p.sortOrder),
  ]);
  return {
    for (final (i, p) in projects.indexed) p.id: ProjectSlug.urlFor(slugs[i]),
  };
}

/// Opens [url] in a new browser tab.
Future<void> openInNewTab(String url) async {
  await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
}

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
    if (demoMode || authState is Authenticated) {
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
    showAppDialog(
      context,
      (_) => BlocProvider.value(
        value: cubit,
        child: ProjectFormView(project: project),
      ),
    );
  }

  Future<void> _confirmDelete(Project project) async {
    final ok = await confirmDelete(context,
        title: 'Delete project?', itemName: project.title);
    if (ok && mounted) {
      context.read<ProjectsCubit>().deleteProject(project.id);
    }
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
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Projects',
                subtitle:
                    'Apps, case studies and what the site shows for each.',
                actions: [
                  ViewToggle(
                    isGrid: _isGridView,
                    onToggle: (isGrid) => setState(() => _isGridView = isGrid),
                  ),
                  AppButton(
                    label: 'Add project',
                    icon: Icons.add_rounded,
                    onPressed: _showProjectForm,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsAndSearch(),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats + Search row ─────────────────────────────────────────────────────

  Widget _buildStatsAndSearch() {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        final projects =
            state is ProjectsLoaded ? state.projects : <Project>[];
        final liveCount = projects
            .where((p) => p.androidStoreUrl != null || p.iosStoreUrl != null)
            .length;
        final featuredCount = projects.where((p) => p.featured).length;

        return Row(
          children: [
            if (projects.isNotEmpty) ...[
              StatChip(
                icon: Icons.folder_outlined,
                count: '${projects.length}',
                label: projects.length == 1 ? 'project' : 'projects',
              ),
              const SizedBox(width: 8),
              if (liveCount > 0) ...[
                StatChip(
                  icon: Icons.storefront_outlined,
                  count: '$liveCount',
                  label: 'live',
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
              ],
              if (featuredCount > 0) ...[
                StatChip(
                  icon: Icons.star_rounded,
                  count: '$featuredCount',
                  label: 'featured',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
              ],
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: SearchField(
                    controller: _searchController,
                    hint: 'Search projects',
                    query: _searchQuery,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading) return _buildShimmer();
        if (state is ProjectsError) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load projects',
            message: state.message,
            actionLabel: 'Retry',
            actionIcon: Icons.refresh_rounded,
            onAction: () => context.read<ProjectsCubit>().fetchProjects(),
            isError: true,
          );
        }
        if (state is ProjectsLoaded) {
          final filtered = _filter(state.projects);
          if (state.projects.isEmpty) {
            return EmptyState(
              icon: Icons.rocket_launch_outlined,
              title: 'No projects yet',
              message: 'Add your first project and it will show on the site.',
              actionLabel: 'Add project',
              actionIcon: Icons.add_rounded,
              onAction: _showProjectForm,
            );
          }
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results for "$_searchQuery"',
              message: 'Try a different title, description or technology.',
            );
          }
          // Slugs depend on every project, not just the filtered ones.
          final urls = caseStudyUrls(state.projects);
          return _buildProjectsView(filtered, urls);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProjectsView(List<Project> projects, Map<String, String> urls) {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.medium),
      switchInCurve: AppMotion.ease,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _isGridView
          ? _GridView(
              key: const ValueKey('grid'),
              projects: projects,
              urls: urls,
              onEdit: _showProjectForm,
              onDelete: _confirmDelete,
            )
          : _ListView(
              key: const ValueKey('list'),
              projects: projects,
              urls: urls,
              onEdit: _showProjectForm,
              onDelete: _confirmDelete,
            ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      child: _isGridView
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.82,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => Container(
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }
}

// ── Grid / List wrappers ──────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final List<Project> projects;
  final Map<String, String> urls;
  final void Function([Project?]) onEdit;
  final void Function(Project) onDelete;

  const _GridView({
    super.key,
    required this.projects,
    required this.urls,
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
        } else if (constraints.maxWidth > 860) {
          columns = 3;
        }
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.78,
          ),
          itemCount: projects.length,
          itemBuilder: (context, i) {
            final p = projects[i];
            final url = urls[p.id];
            return ProjectGridItem(
              key: ValueKey(p.id),
              project: p,
              onEdit: () => onEdit(p),
              onDelete: () => onDelete(p),
              onOpenCaseStudy: url == null ? null : () => openInNewTab(url),
            );
          },
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List<Project> projects;
  final Map<String, String> urls;
  final void Function([Project?]) onEdit;
  final void Function(Project) onDelete;

  const _ListView({
    super.key,
    required this.projects,
    required this.urls,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: 24),
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
        final url = urls[p.id];
        return Padding(
          key: ValueKey(p.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: ProjectListItem(
            project: p,
            onEdit: () => onEdit(p),
            onDelete: () => onDelete(p),
            onOpenCaseStudy: url == null ? null : () => openInNewTab(url),
            showDragHandle: true,
            dragIndex: i,
          ),
        );
      },
    );
  }
}
