import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/widgets/unsaved_changes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/expertise_cubit.dart';
import '../bloc/expertise_state.dart';
import '../../domain/entities/expertise_entity.dart';
import '../../data/models/expertise_model.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';

class ExpertisePage extends StatefulWidget {
  const ExpertisePage({super.key});

  @override
  State<ExpertisePage> createState() => _ExpertisePageState();
}

class _ExpertisePageState extends State<ExpertisePage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (demoMode || authState is Authenticated) {
      final state = context.read<ExpertiseCubit>().state;
      if (state is ExpertiseInitial || state is ExpertiseError) {
        context.read<ExpertiseCubit>().fetchExpertise();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final expState = context.read<ExpertiseCubit>().state;
          if (expState is ExpertiseInitial || expState is ExpertiseError) {
            context.read<ExpertiseCubit>().fetchExpertise();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Expertise',
                subtitle: 'Skills and proficiency levels shown on the site.',
                actions: [
                  AppButton(
                    label: 'Add skill',
                    icon: Icons.add_rounded,
                    onPressed: () => _showExpertiseForm(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Content Section
              Expanded(
                child: BlocBuilder<ExpertiseCubit, ExpertiseState>(
                  builder: (context, state) {
                    if (state is ExpertiseLoading) {
                      return _buildShimmerLoading();
                    } else if (state is ExpertiseError) {
                      return EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load skills',
                        message: state.message,
                        isError: true,
                        actionLabel: 'Retry',
                        actionIcon: Icons.refresh_rounded,
                        onAction: () => context.read<ExpertiseCubit>().fetchExpertise(),
                      );
                    } else if (state is ExpertiseLoaded) {
                      if (state.expertise.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Get all unique categories for filter
                      final categories = {'All', ...state.expertise.map((e) => e.category)};

                      // Filter skills
                      final filteredSkills = _selectedCategory == 'All'
                          ? state.expertise
                          : state.expertise.where((e) => e.category == _selectedCategory).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCategory = cat;
                                        });
                                      }
                                    },
                                    selectedColor: AppColors.primarySoft,
                                    checkmarkColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    backgroundColor: AppColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Skills Grid/List
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(24),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, crossAxisSpacing: 24, mainAxisSpacing: 24, mainAxisExtent: 162,
                                ),
                                itemCount: filteredSkills.length,
                                itemBuilder: (context, index) {
                                  final skill = filteredSkills[index];
                                  return _buildSkillCard(skill, context);
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard(Expertise skill, BuildContext context) {
    return HoverBuilder(
      builder: (context, isHovered) {
        return MouseRegion(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: isHovered ? AppShadows.raised : AppShadows.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered ? AppColors.borderStrong : AppColors.border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isHovered ? skill.color : AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: skill.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: skill.color.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: AppColors.primary,
                            onPressed: () => _showExpertiseForm(context, skill),
                            tooltip: 'Edit Skill',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.danger,
                            onPressed: () => _confirmDelete(context, skill),
                            tooltip: 'Delete Skill',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Proficiency',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        ),
                        Text(
                          '${skill.percentage}%',
                          style: TextStyle(
                            color: skill.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: skill.percentage / 100.0,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(skill.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, crossAxisSpacing: 24, mainAxisSpacing: 24, mainAxisExtent: 162,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.star_outline_rounded,
      title: 'No skills yet',
      message: 'Add a skill and it will show on the site.',
      actionLabel: 'Add skill',
      actionIcon: Icons.add_rounded,
      onAction: () => _showExpertiseForm(context),
    );
  }

  void _confirmDelete(BuildContext context, Expertise skill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Skill?'),
        content: Text(
          'Are you sure you want to delete "${skill.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ExpertiseCubit>().deleteExpertise(skill.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExpertiseForm(BuildContext context, [Expertise? skill]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.ink.withValues(alpha: 0.32),
      transitionDuration: AppMotion.of(context, AppMotion.slow),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BlocProvider.value(
          value: context.read<ExpertiseCubit>(),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: AppMotion.ease),
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: AppMotion.ease)),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(32),
                child: ExpertiseFormView(skill: skill),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExpertiseFormView extends StatefulWidget {
  final Expertise? skill;

  const ExpertiseFormView({super.key, this.skill});

  @override
  State<ExpertiseFormView> createState() => _ExpertiseFormViewState();
}

class _ExpertiseFormViewState extends State<ExpertiseFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  double _percentage = 80;
  late TextEditingController _colorController;

  final List<String> _categoryPresets = ['Mobile', 'Frontend', 'Backend', 'DevOps', 'Design', 'Other'];
  
  final List<Color> _colorPresets = [
    const Color(0xFF0E7490), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFFEB3B), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.skill?.title ?? '');
    _categoryController = TextEditingController(text: widget.skill?.category ?? 'Mobile');
    _percentage = widget.skill?.percentage.toDouble() ?? 80;

    String hexColor = widget.skill != null
        ? widget.skill!.color.value.toRadixString(16).substring(2).toUpperCase()
        : '0E7490';
    _colorController = TextEditingController(text: hexColor);
    _initialSnapshot = _snapshot();
  }

  /// Everything the form edits, to tell whether it has unsaved changes.
  late final String _initialSnapshot;

  String _snapshot() => formSnapshot([_titleController, _categoryController, _colorController, _percentage]);

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Color skillColor = _colorPresets[0];
      try {
        skillColor = Color(
          int.parse('FF${_colorController.text.replaceAll('#', '')}', radix: 16),
        );
      } catch (_) {}

      final newSkill = ExpertiseModel(
        id: widget.skill?.id ?? '',
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        percentage: _percentage.toInt(),
        color: skillColor,
        icon: widget.skill?.icon,
      );

      if (widget.skill == null) {
        context.read<ExpertiseCubit>().addExpertise(newSkill);
      } else {
        context.read<ExpertiseCubit>().updateExpertise(newSkill);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => UnsavedChangesGuard(
        isDirty: () => _snapshot() != _initialSnapshot,
        child: _buildForm(context),
      );

  Widget _buildForm(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.skill == null ? 'Add Expertise Skill' : 'Edit Expertise Skill',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        IconActionButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Close',
                          size: 36,
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 32),

                    // Skill Name Input
                    const Text('Skill Title *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: 'e.g. Flutter, NodeJS, Git',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Skill title is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Category Select
                    const Text('Category *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _categoryPresets.contains(_categoryController.text) ? _categoryController.text : 'Other',
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.ink),
                      decoration: InputDecoration(
                      ),
                      items: _categoryPresets.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _categoryController.text = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    if (_categoryController.text == 'Other') ...[
                      const Text('Custom Category Name', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                        onChanged: (val) {
                          _categoryController.text = val;
                        },
                        style: const TextStyle(color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText: 'e.g. Databases, Machine Learning',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Percentage Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Proficiency Level', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                        Text('${_percentage.toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _percentage,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (val) {
                          setState(() {
                            _percentage = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hex Color Input & Preset Selector
                    const Text('Display Color (Hex)', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            style: const TextStyle(color: AppColors.ink),
                            decoration: InputDecoration(
                              prefixText: '# ',
                              prefixStyle: const TextStyle(color: AppColors.textTertiary),
                              hintText: '0E7490',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Color is required';
                              try {
                                int.parse(v.replaceAll('#', ''), radix: 16);
                                return null;
                              } catch (_) {
                                return 'Invalid hex color';
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Preset color circles
                        Wrap(
                          spacing: 8,
                          children: _colorPresets.map((c) {
                            final hexStr = c.value.toRadixString(16).substring(2).toUpperCase();
                            final isSelected = _colorController.text.replaceAll('#', '').toUpperCase() == hexStr;
                            return Pressable(
                              onTap: () {
                                setState(() {
                                  _colorController.text = hexStr;
                                });
                              },
                              pressedScale: 0.92,
                              focusRadius: 999,
                              semanticLabel: 'Colour #$hexStr',
                              toggled: isSelected,
                              builder: (context, _) => Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.ink : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: 'Cancel',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          label: widget.skill == null ? 'Create Skill' : 'Save Changes',
                          icon: Icons.check_rounded,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
