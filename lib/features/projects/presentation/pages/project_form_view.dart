import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/image_upload_field.dart';
import 'package:admin_dashboard/core/widgets/multiple_image_upload_field.dart';

import '../../domain/entities/project_entity.dart';
import '../bloc/projects_cubit.dart';
import '../bloc/projects_state.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kPresetColors = [
  Color(0xFF00D9FF), // cyan
  Color(0xFF7B2CBF), // purple
  Color(0xFF6366F1), // indigo
  Color(0xFF4ADE80), // green
  Color(0xFFFBBF24), // amber
  Color(0xFFF97316), // orange
  Color(0xFFEF4444), // red
  Color(0xFFEC4899), // pink
];

enum _Tab { basic, media, links }

// ── Main widget ────────────────────────────────────────────────────────────────

class ProjectFormView extends StatefulWidget {
  final Project? project;
  const ProjectFormView({super.key, this.project});

  @override
  State<ProjectFormView> createState() => _ProjectFormViewState();
}

class _ProjectFormViewState extends State<ProjectFormView>
    with SingleTickerProviderStateMixin {
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
  late final ValueNotifier<List<String>> _galleryNotifier;

  Color _previewColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.project?.title ?? '');
    _descController =
        TextEditingController(text: widget.project?.description ?? '');
    _techController =
        TextEditingController(text: widget.project?.tech.join(', ') ?? '');
    _downloadsController =
        TextEditingController(text: widget.project?.downloads ?? '');

    final hex = widget.project != null
        ? _colorToHex(widget.project!.color)
        : '00D9FF';
    _colorController = TextEditingController(text: hex);
    _previewColor = _parseHex(hex) ?? AppColors.primary;

    _imageUrlController =
        TextEditingController(text: widget.project?.imageUrl ?? '');
    _logoUrlController =
        TextEditingController(text: widget.project?.logoUrl ?? '');
    _androidUrlController =
        TextEditingController(text: widget.project?.androidStoreUrl ?? '');
    _iosUrlController =
        TextEditingController(text: widget.project?.iosStoreUrl ?? '');
    _videoUrlController =
        TextEditingController(text: widget.project?.videoUrl ?? '');
    _galleryNotifier = ValueNotifier<List<String>>(
      widget.project?.galleryImages != null
          ? List.from(widget.project!.galleryImages!)
          : [],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _techController.dispose();
    _downloadsController.dispose();
    _colorController.dispose();
    _imageUrlController.dispose();
    _logoUrlController.dispose();
    _androidUrlController.dispose();
    _iosUrlController.dispose();
    _videoUrlController.dispose();
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

  // ── Save ───────────────────────────────────────────────────────────────────

  void _save() {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _activeTab = _Tab.basic);
      return;
    }
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
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      androidStoreUrl: _androidUrlController.text.trim().isEmpty
          ? null
          : _androidUrlController.text.trim(),
      iosStoreUrl: _iosUrlController.text.trim().isEmpty
          ? null
          : _iosUrlController.text.trim(),
      videoUrl: _videoUrlController.text.trim().isEmpty
          ? null
          : _videoUrlController.text.trim(),
      galleryImages:
          _galleryNotifier.value.isEmpty ? null : _galleryNotifier.value,
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
    final dialogWidth = (size.width * 0.90).clamp(440.0, 1060.0);
    final isWide = size.width > 820;

    return BlocConsumer<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (!_isSaving) return;
        if (state is ProjectsLoaded) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          final isNew = widget.project == null;
          Navigator.of(context).pop();
          messenger?.showSnackBar(
              _successSnackBar(isNew ? 'Project created!' : 'Project updated!'));
        } else if (state is ProjectsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(_errorSnackBar(state.message));
        }
      },
      builder: (context, state) {
        return Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: size.height * 0.9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Gradient border
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _previewColor.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 80,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _previewColor.withValues(alpha: 0.12),
                blurRadius: 100,
                spreadRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.8),
                  radius: 0.75,
                  colors: [
                    _previewColor.withValues(alpha: 0.06),
                    AppColors.surface,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Flexible(
                    child: Form(
                      key: _formKey,
                      child: isWide
                          ? _buildWideLayout()
                          : _buildNarrowLayout(),
                    ),
                  ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _previewColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _previewColor.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                    color: _previewColor.withValues(alpha: 0.25),
                    blurRadius: 12)
              ],
            ),
            child: Icon(
              widget.project == null
                  ? Icons.add_circle_outline_rounded
                  : Icons.edit_note_rounded,
              color: _previewColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project == null
                      ? 'Create New Project'
                      : 'Edit Project',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
                Text(
                  widget.project == null
                      ? 'Fill in the details to add a portfolio project'
                      : 'Editing "${widget.project!.title}"',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.38)),
                ),
              ],
            ),
          ),
          _CloseButton(
              enabled: !_isSaving,
              onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          _Tab1(
            label: 'Basic Info',
            icon: Icons.info_outline_rounded,
            active: _activeTab == _Tab.basic,
            color: _previewColor,
            onTap: () => setState(() => _activeTab = _Tab.basic),
          ),
          const SizedBox(width: 6),
          _Tab1(
            label: 'Media',
            icon: Icons.perm_media_outlined,
            active: _activeTab == _Tab.media,
            color: _previewColor,
            onTap: () => setState(() => _activeTab = _Tab.media),
          ),
          const SizedBox(width: 6),
          _Tab1(
            label: 'Store Links',
            icon: Icons.store_rounded,
            active: _activeTab == _Tab.links,
            color: _previewColor,
            onTap: () => setState(() => _activeTab = _Tab.links),
          ),
        ],
      ),
    );
  }

  // ── Layouts ────────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildActiveTab(),
          ),
        ),
        VerticalDivider(
            color: Colors.white.withValues(alpha: 0.06), width: 1),
        SizedBox(
          width: 240,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
      duration: const Duration(milliseconds: 200),
      child: switch (_activeTab) {
        _Tab.basic => _buildBasicTab(),
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
        _field('Project Title', _titleController, required: true),
        const SizedBox(height: 14),
        _field('Description', _descController,
            required: true, maxLines: 4),
        const SizedBox(height: 14),
        _field('Technologies', _techController,
            required: true,
            hint: 'Flutter, Firebase, Dart  (comma separated)'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _field('Downloads / Stats', _downloadsController,
                  required: true, hint: '10K+ Downloads'),
            ),
            const SizedBox(width: 14),
            Expanded(child: _colorField()),
          ],
        ),
        const SizedBox(height: 10),
        PresetColorRow(selected: _previewColor, onSelected: _pickPreset),
      ],
    );
  }

  Widget _buildMediaTab() {
    return Column(
      key: const ValueKey('media'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageUploadField(
          label: 'Cover Image',
          controller: _imageUrlController,
          storagePath: 'projects/covers',
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: 'Logo / Icon',
          controller: _logoUrlController,
          storagePath: 'projects/logos',
        ),
        const SizedBox(height: 20),
        MultipleImageUploadField(
          label: 'Gallery Screenshots',
          imagesNotifier: _galleryNotifier,
          storagePath: 'projects/gallery',
        ),
        const SizedBox(height: 20),
        _field('Video Demo URL', _videoUrlController,
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
          'Android Play Store URL',
          _androidUrlController,
          icon: Icons.android_rounded,
          color: const Color(0xFF4ADE80),
          hint: 'https://play.google.com/...',
        ),
        const SizedBox(height: 16),
        _labeledField(
          'iOS App Store URL',
          _iosUrlController,
          icon: Icons.apple_rounded,
          color: Colors.white54,
          hint: 'https://apps.apple.com/...',
        ),
      ],
    );
  }

  // ── Preview card ───────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _previewColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: _previewColor.withValues(alpha: 0.6),
                        blurRadius: 6)
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Live Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<List<String>>(
          valueListenable: _galleryNotifier,
          builder: (context, gallery, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _previewColor.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.01),
                    AppColors.surface,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                border: Border.all(
                    color: _previewColor.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: _previewColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover area
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _imageUrlController.text.isNotEmpty
                              ? Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      _placeholderCover(),
                                )
                              : _placeholderCover(),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.4, 1.0],
                                  colors: [
                                    Colors.transparent,
                                    AppColors.surface
                                        .withValues(alpha: 0.95),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Downloads badge
                          if (_downloadsController.text.isNotEmpty)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.download_rounded,
                                        size: 9,
                                        color: AppColors.primary),
                                    const SizedBox(width: 3),
                                    Text(
                                      _downloadsController.text,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Live badge
                          if (_androidUrlController.text.isNotEmpty ||
                              _iosUrlController.text.isNotEmpty)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: _SmallLiveBadge(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 7),
                              decoration: BoxDecoration(
                                color: _previewColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _previewColor
                                        .withValues(alpha: 0.7),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: _titleController,
                                builder: (context, value, _) => Text(
                                  _titleController.text.isEmpty
                                      ? 'Project Title'
                                      : _titleController.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _titleController.text.isEmpty
                                        ? Colors.white24
                                        : Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ValueListenableBuilder(
                          valueListenable: _descController,
                          builder: (context, value, _) => Text(
                            _descController.text.isEmpty
                                ? 'Description will appear here…'
                                : _descController.text,
                            style: TextStyle(
                              fontSize: 10,
                              color: _descController.text.isEmpty
                                  ? Colors.white12
                                  : Colors.white.withValues(alpha: 0.38),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: _techController,
                          builder: (context, value, _) {
                            final tags = _techController.text
                                .split(',')
                                .map((t) => t.trim())
                                .where((t) => t.isNotEmpty)
                                .take(3)
                                .toList();
                            if (tags.isEmpty) return const SizedBox.shrink();
                            return Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: tags
                                  .map((t) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _previewColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: _previewColor
                                                  .withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          t,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: _previewColor
                                                .withValues(alpha: 0.9),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _previewColor.withValues(alpha: 0.15),
            _previewColor.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.rocket_launch_rounded,
            size: 28, color: _previewColor.withValues(alpha: 0.3)),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          // Tab progress dots
          Row(
            children: _Tab.values.map((t) {
              final active = t == _activeTab;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: active
                      ? _previewColor
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          TextButton(
            onPressed:
                _isSaving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 14)),
          ),
          const SizedBox(width: 10),
          _SaveButton(
            isSaving: _isSaving,
            isEdit: widget.project != null,
            color: _previewColor,
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(
        label: required ? '$label *' : label,
        hint: hint,
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
    required Color color,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label: label, hint: hint).copyWith(
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  Widget _colorField() {
    return TextFormField(
      controller: _colorController,
      maxLength: 6,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'monospace',
        letterSpacing: 1.2,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
      ],
      onChanged: _onColorChanged,
      decoration: _inputDecoration(label: 'Theme Color').copyWith(
        counterText: '',
        prefixText: '# ',
        prefixStyle: TextStyle(
          color: _previewColor,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _previewColor,
              borderRadius: BorderRadius.circular(7),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                    color: _previewColor.withValues(alpha: 0.55),
                    blurRadius: 8)
              ],
            ),
          ),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (_parseHex(v) == null) return 'Must be 6 hex chars (e.g. 00D9FF)';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.09)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _previewColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────

  static SnackBar _successSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF4ADE80), size: 18),
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        duration: const Duration(seconds: 3),
      );

  static SnackBar _errorSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        duration: const Duration(seconds: 4),
      );
}

// ── Tab button ─────────────────────────────────────────────────────────────────

class _Tab1 extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _Tab1({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  State<_Tab1> createState() => _Tab1State();
}

class _Tab1State extends State<_Tab1> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.active
                ? widget.color.withValues(alpha: 0.14)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.active
                  ? widget.color.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.active
                    ? widget.color
                    : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.active
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.active
                      ? widget.color
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
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
        return GestureDetector(
          onTap: () => onSelected(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: c.withValues(alpha: 0.7), blurRadius: 10)]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Close button ───────────────────────────────────────────────────────────────

class _CloseButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _CloseButton({required this.enabled, required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.redAccent.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _hovered
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.09),
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: _hovered ? Colors.redAccent : Colors.white38,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ── Save button ────────────────────────────────────────────────────────────────

class _SaveButton extends StatefulWidget {
  final bool isSaving;
  final bool isEdit;
  final Color color;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isSaving,
    required this.isEdit,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: (!widget.isSaving && _hovered) ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered && !widget.isSaving
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: widget.isSaving ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.black,
              disabledBackgroundColor:
                  widget.color.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black54),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          widget.isEdit
                              ? Icons.save_rounded
                              : Icons.check_rounded,
                          size: 17),
                      const SizedBox(width: 7),
                      Text(widget.isEdit
                          ? 'Save Changes'
                          : 'Create Project'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Small live badge for preview card ─────────────────────────────────────────

class _SmallLiveBadge extends StatelessWidget {
  const _SmallLiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text('Live',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4ADE80))),
        ],
      ),
    );
  }
}
