import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/image_upload_field.dart';
import 'package:admin_dashboard/core/widgets/multiple_image_upload_field.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';
import 'package:admin_dashboard/core/widgets/unsaved_changes.dart';

import '../../domain/entities/project_entity.dart';
import '../../domain/project_slug.dart';
import '../bloc/projects_cubit.dart';
import '../bloc/projects_state.dart';
import '../widgets/project_badges.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kPresetColors = [
  Color(0xFF0E7490), // teal
  Color(0xFF2563EB), // blue
  Color(0xFF6366F1), // indigo
  Color(0xFF7C3AED), // violet
  Color(0xFF0F9D58), // green
  Color(0xFFD97706), // amber
  Color(0xFFE4572E), // orange
  Color(0xFFDB2777), // pink
];

enum _Tab { basic, caseStudy, media, links }

const _highlightHelp =
    'One short sentence. Only facts you can stand behind.';
const _storyHelp = 'Leave empty to hide this part on the site.';

// ── Main widget ────────────────────────────────────────────────────────────────

class ProjectFormView extends StatefulWidget {
  final Project? project;
  const ProjectFormView({super.key, this.project});

  @override
  State<ProjectFormView> createState() => _ProjectFormViewState();
}

class _ProjectFormViewState extends State<ProjectFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  _Tab _activeTab = _Tab.basic;

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _techController;
  late final TextEditingController _downloadsController;
  late final TextEditingController _colorController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _androidUrlController;
  late final TextEditingController _iosUrlController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _highlightController;
  late final TextEditingController _problemController;
  late final TextEditingController _roleController;
  late final TextEditingController _outcomeController;
  late final TextEditingController _slugController;
  late final ValueNotifier<List<String>> _galleryNotifier;
  late bool _featured;

  Color _previewColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _techController = TextEditingController(text: p?.tech.join(', ') ?? '');
    _downloadsController = TextEditingController(text: p?.downloads ?? '');

    final hex = p != null ? _colorToHex(p.color) : '0E7490';
    _colorController = TextEditingController(text: hex);
    _previewColor = _parseHex(hex) ?? AppColors.primary;

    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _logoUrlController = TextEditingController(text: p?.logoUrl ?? '');
    _androidUrlController =
        TextEditingController(text: p?.androidStoreUrl ?? '');
    _iosUrlController = TextEditingController(text: p?.iosStoreUrl ?? '');
    _videoUrlController = TextEditingController(text: p?.videoUrl ?? '');
    _highlightController = TextEditingController(text: p?.highlight ?? '');
    _problemController = TextEditingController(text: p?.problem ?? '');
    _roleController = TextEditingController(text: p?.role ?? '');
    _outcomeController = TextEditingController(text: p?.outcome ?? '');
    _slugController = TextEditingController(text: p?.slug ?? '');
    _featured = p?.featured ?? false;
    _galleryNotifier = ValueNotifier<List<String>>(
      p?.galleryImages != null ? List.from(p!.galleryImages!) : [],
    );
    _initialSnapshot = _snapshot();
  }

  /// Everything the form edits, to tell whether it has unsaved changes.
  late final String _initialSnapshot;

  String _snapshot() => formSnapshot([
        _titleController, _descController, _techController, _downloadsController,
        _colorController, _imageUrlController, _logoUrlController, _androidUrlController,
        _iosUrlController, _videoUrlController, _highlightController, _problemController,
        _roleController, _outcomeController, _slugController, _featured, _galleryNotifier.value,
      ]);

  @override
  void dispose() {
    for (final c in [
      _titleController,
      _descController,
      _techController,
      _downloadsController,
      _colorController,
      _imageUrlController,
      _logoUrlController,
      _androidUrlController,
      _iosUrlController,
      _videoUrlController,
      _highlightController,
      _problemController,
      _roleController,
      _outcomeController,
      _slugController,
    ]) {
      c.dispose();
    }
    _galleryNotifier.dispose();
    super.dispose();
  }

  // ── Color helpers ──────────────────────────────────────────────────────────

  String _colorToHex(Color c) {
    final argb = c.toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color? _parseHex(String raw) {
    final hex = raw.replaceAll('#', '').trim();
    if (hex.length != 6) return null;
    final value = int.tryParse('FF$hex', radix: 16);
    return value != null ? Color(value) : null;
  }

  void _onColorChanged(String value) {
    final parsed = _parseHex(value);
    if (parsed != null) setState(() => _previewColor = parsed);
  }

  void _pickPreset(Color color) {
    _colorController.text = _colorToHex(color);
    setState(() => _previewColor = color);
  }

  String? _nonBlank(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  // ── Slug / case study URL ──────────────────────────────────────────────────

  /// The slug the site will use for this project once saved, accounting for
  /// the other projects (a repeated slug gets -2, -3, ... like on the site).
  ({String slug, bool generated, bool deduped}) _resolvedSlug() {
    final title = _titleController.text.trim();
    final own = ProjectSlug.clean(_slugController.text);
    final base = ProjectSlug.effective(slug: _slugController.text, title: title);

    final state = context.read<ProjectsCubit>().state;
    final others = state is ProjectsLoaded
        ? state.projects.where((p) => p.id != widget.project?.id).toList()
        : <Project>[];
    final entries = [
      for (final p in others)
        (title: p.title, slug: p.slug, featured: p.featured, sortOrder: p.sortOrder),
      (
        title: title,
        slug: own,
        featured: _featured,
        sortOrder: widget.project?.sortOrder ?? others.length,
      ),
    ];
    final unique = ProjectSlug.unique(entries).last;
    return (slug: unique, generated: own == null, deduped: unique != base);
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  void _save() {
    if (_isSaving) return;
    final form = _formKey.currentState;
    if (form != null && !form.validate()) return;
    // Required fields live on the Basic tab; check them even when another
    // tab is open (only the visible tab's fields are in the Form).
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _techController.text.trim().isEmpty ||
        _downloadsController.text.trim().isEmpty) {
      setState(() => _activeTab = _Tab.basic);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _formKey.currentState?.validate());
      return;
    }

    final state = context.read<ProjectsCubit>().state;
    final count = state is ProjectsLoaded ? state.projects.length : 0;

    final entity = Project(
      id: widget.project?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      tech: _techController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      color: _parseHex(_colorController.text) ?? AppColors.primary,
      downloads: _downloadsController.text.trim(),
      imageUrl: _nonBlank(_imageUrlController),
      logoUrl: _nonBlank(_logoUrlController),
      androidStoreUrl: _nonBlank(_androidUrlController),
      iosStoreUrl: _nonBlank(_iosUrlController),
      videoUrl: _nonBlank(_videoUrlController),
      galleryImages:
          _galleryNotifier.value.isEmpty ? null : _galleryNotifier.value,
      // Keep the dragged position; a new project goes to the end.
      sortOrder: widget.project?.sortOrder ?? count,
      featured: _featured,
      highlight: _nonBlank(_highlightController),
      problem: _nonBlank(_problemController),
      role: _nonBlank(_roleController),
      outcome: _nonBlank(_outcomeController),
      // Stored the way the site cleans it, so the URL shown here is exact.
      slug: ProjectSlug.clean(_slugController.text),
    );

    setState(() => _isSaving = true);
    if (widget.project == null) {
      context.read<ProjectsCubit>().addProject(entity);
    } else {
      context.read<ProjectsCubit>().updateProject(entity);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = (size.width * 0.90).clamp(440.0, 1080.0);
    final isWide = size.width > 860;

    return BlocConsumer<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (!_isSaving) return;
        if (state is ProjectsLoaded) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          final isNew = widget.project == null;
          Navigator.of(context).pop();
          messenger?.showSnackBar(
              _snackBar(isNew ? 'Project created' : 'Project saved'));
        } else if (state is ProjectsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(_snackBar(state.message, error: true));
        }
      },
      builder: (context, state) {
        return UnsavedChangesGuard(
          isDirty: () => !_isSaving && _snapshot() != _initialSnapshot,
          child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: size.height * 0.92),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.raised,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildTabBar(),
                const Divider(height: 1),
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final isNew = widget.project == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 20, 14),
      child: Row(
        children: [
          ColorDot(color: _previewColor, size: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNew ? 'New project' : 'Edit project',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isNew
                      ? 'Add a project to the portfolio site.'
                      : widget.project!.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconActionButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            size: 36,
            onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    const tabs = [
      (_Tab.basic, 'Basics', Icons.info_outline_rounded),
      (_Tab.caseStudy, 'Case study', Icons.article_outlined),
      (_Tab.media, 'Media', Icons.perm_media_outlined),
      (_Tab.links, 'Store links', Icons.storefront_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (tab, label, icon) in tabs)
                _TabPill(
                  label: label,
                  icon: icon,
                  active: _activeTab == tab,
                  onTap: () => setState(() => _activeTab = tab),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layouts ────────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: _buildActiveTab(),
          ),
        ),
        Container(
          width: 300,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: _buildPreviewCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildActiveTab(),
    );
  }

  // ── Tab content ────────────────────────────────────────────────────────────

  Widget _buildActiveTab() {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.medium),
      switchInCurve: AppMotion.ease,
      child: switch (_activeTab) {
        _Tab.basic => _buildBasicTab(),
        _Tab.caseStudy => _buildCaseStudyTab(),
        _Tab.media => _buildMediaTab(),
        _Tab.links => _buildLinksTab(),
      },
    );
  }

  Widget _buildBasicTab() {
    return Column(
      key: const ValueKey('basic'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Project title', _titleController, required: true),
        const SizedBox(height: 16),
        _field('Description', _descController, required: true, maxLines: 4),
        const SizedBox(height: 16),
        _field('Technologies', _techController,
            required: true, hint: 'Flutter, Firebase, Dart (comma separated)'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field('Downloads / status', _downloadsController,
                  required: true, hint: '10,000+'),
            ),
            const SizedBox(width: 16),
            Expanded(child: _colorField()),
          ],
        ),
        const SizedBox(height: 12),
        PresetColorRow(selected: _previewColor, onSelected: _pickPreset),
        const SizedBox(height: 28),
        const _SectionLabel(
          title: 'On the site',
          subtitle: 'How this project is presented in the projects list.',
        ),
        const SizedBox(height: 14),
        _FeaturedSwitch(
          value: _featured,
          onChanged: (v) => setState(() => _featured = v),
        ),
        const SizedBox(height: 16),
        _field(
          'Highlight',
          _highlightController,
          hint: 'Example: Rated 4.8 by 1,000+ store reviewers',
          helper: _highlightHelp,
          maxLength: 120,
        ),
      ],
    );
  }

  Widget _buildCaseStudyTab() {
    return Column(
      key: const ValueKey('caseStudy'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(
          title: 'Case study page',
          subtitle:
              'The project\'s own page on the site. Each part below is shown '
              'only when it has text.',
        ),
        const SizedBox(height: 16),
        _slugField(),
        const SizedBox(height: 20),
        _field('The problem', _problemController,
            maxLines: 4, helper: _storyHelp),
        const SizedBox(height: 16),
        _field('My role', _roleController, maxLines: 4, helper: _storyHelp),
        const SizedBox(height: 16),
        _field('The outcome', _outcomeController,
            maxLines: 4, helper: _storyHelp),
      ],
    );
  }

  Widget _buildMediaTab() {
    return Column(
      key: const ValueKey('media'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageUploadField(
          label: 'Cover image',
          controller: _imageUrlController,
          storagePath: 'projects/covers',
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: 'Logo / icon',
          controller: _logoUrlController,
          storagePath: 'projects/logos',
        ),
        const SizedBox(height: 20),
        MultipleImageUploadField(
          label: 'Gallery screenshots',
          imagesNotifier: _galleryNotifier,
          storagePath: 'projects/gallery',
        ),
        const SizedBox(height: 20),
        _field('Video demo URL', _videoUrlController,
            hint: 'https://youtube.com/watch?v=...'),
      ],
    );
  }

  Widget _buildLinksTab() {
    return Column(
      key: const ValueKey('links'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledField(
          'Google Play URL',
          _androidUrlController,
          icon: Icons.android_rounded,
          hint: 'https://play.google.com/...',
        ),
        const SizedBox(height: 16),
        _labeledField(
          'App Store URL',
          _iosUrlController,
          icon: Icons.apple_rounded,
          hint: 'https://apps.apple.com/...',
        ),
      ],
    );
  }

  // ── Slug field with live URL ───────────────────────────────────────────────

  Widget _slugField() {
    return AnimatedBuilder(
      animation: Listenable.merge([_slugController, _titleController]),
      builder: (context, _) {
        final r = _resolvedSlug();
        final url = ProjectSlug.urlFor(r.slug);
        final note = r.deduped
            ? 'Another project already uses this name, so the site adds a number.'
            : r.generated
                ? 'Empty: the site makes this from the title.'
                : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _slugController,
              style: AppFonts.monoStyle(fontSize: 14, color: AppColors.ink),
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              decoration: InputDecoration(
                labelText: 'URL name (slug)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: ProjectSlug.fromTitle(_titleController.text),
                hintStyle: AppFonts.monoStyle(
                    fontSize: 14, color: AppColors.textTertiary),
                helperText: 'Lowercase letters, digits and dashes. '
                    'Leave empty to use the title.',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          url,
                          style: AppFonts.monoStyle(
                              fontSize: 12.5, color: AppColors.ink),
                        ),
                        if (note != null) ...[
                          const SizedBox(height: 3),
                          Text(note,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconActionButton(
                    icon: Icons.copy_rounded,
                    tooltip: 'Copy URL',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.maybeOf(context)
                          ?.showSnackBar(_snackBar('URL copied'));
                    },
                  ),
                  if (widget.project != null) ...[
                    const SizedBox(width: 6),
                    IconActionButton(
                      icon: Icons.arrow_outward_rounded,
                      tooltip: 'Open case study in a new tab',
                      onPressed: () => launchUrl(Uri.parse(url),
                          webOnlyWindowName: '_blank'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Preview card ───────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: Listenable.merge([
            _titleController,
            _descController,
            _techController,
            _highlightController,
            _downloadsController,
            _imageUrlController,
          ]),
          builder: (context, _) {
            final title = _titleController.text.trim();
            final highlight = _highlightController.text.trim();
            final desc = _descController.text.trim();
            final tags = _techController.text
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            final isLive = _androidUrlController.text.isNotEmpty ||
                _iosUrlController.text.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.slow),
                    height: 3,
                    color: _previewColor,
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _imageUrlController.text.isNotEmpty
                            ? Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => _placeholderCover(),
                              )
                            : _placeholderCover(),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Wrap(spacing: 6, children: [
                            if (_featured) const FeaturedBadge(),
                            if (isLive) const LiveBadge(),
                          ]),
                        ),
                        if (_downloadsController.text.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: DownloadsBadge(
                                label: _downloadsController.text),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ColorDot(color: _previewColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title.isEmpty ? 'Project title' : title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  color: title.isEmpty
                                      ? AppColors.textTertiary
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (highlight.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            highlight,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          desc.isEmpty ? 'Description appears here.' : desc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          TechChips(tech: tags, max: 3),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _placeholderCover() {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _previewColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.image_outlined, size: 20, color: _previewColor),
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final isEdit = widget.project != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Fields marked * are required.',
              style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textTertiary.withValues(alpha: 0.62 / 0.62)),
            ),
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          AppButton(
            label: isEdit ? 'Save changes' : 'Create project',
            icon: isEdit ? Icons.check_rounded : Icons.add_rounded,
            isLoading: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  // ── Field helpers ──────────────────────────────────────────────────────────

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    String? hint,
    String? helper,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 3 : 1,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.ink, fontSize: 14.5, height: 1.45),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        helperText: helper,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.ink, fontSize: 14.5),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _colorField() {
    return TextFormField(
      controller: _colorController,
      maxLength: 6,
      style: AppFonts.monoStyle(fontSize: 14, color: AppColors.ink),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
      ],
      onChanged: _onColorChanged,
      decoration: InputDecoration(
        labelText: 'Project colour',
        counterText: '',
        prefixText: '# ',
        prefixStyle: AppFonts.monoStyle(
            fontSize: 14, color: AppColors.textTertiary),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.slow),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _previewColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (_parseHex(v) == null) return 'Use 6 hex characters, e.g. 0E7490';
        return null;
      },
    );
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────

  static SnackBar _snackBar(String message, {bool error = false}) => SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: error ? const Color(0xFFFDA29B) : const Color(0xFF75E0A7),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        margin: const EdgeInsets.all(24),
        duration: Duration(seconds: error ? 4 : 3),
      );
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.2,
            )),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
      ],
    );
  }
}

// ── Featured switch ─────────────────────────────────────────────────────────

class _FeaturedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FeaturedSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => onChanged(!value),
      pressedScale: 0.99,
      semanticLabel: 'Featured project',
      toggled: value,
      builder: (context, hovered) => AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.ease,
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primarySoft
              : hovered
                  ? AppColors.background
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.borderStrong,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 20,
              color: value ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured project',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Listed first on the site, with a "Featured project" badge.',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ── Tab pill ───────────────────────────────────────────────────────────────

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered) => AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.medium),
        curve: AppMotion.ease,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active || hovered
                    ? AppColors.ink
                    : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active || hovered
                    ? AppColors.ink
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Preset color picker ────────────────────────────────────────────────────────

class PresetColorRow extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelected;

  const PresetColorRow(
      {super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kPresetColors.map((c) {
        final isActive = c.toARGB32() == selected.toARGB32();
        return Pressable(
          onTap: () => onSelected(c),
          pressedScale: 0.92,
          semanticLabel: 'Use colour',
          focusRadius: 999,
          builder: (context, hovered) => AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.ease,
            width: 26,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.ink
                    : hovered
                        ? AppColors.borderStrong
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          ),
        );
      }).toList(),
    );
  }
}
