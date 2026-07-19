import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/experience_cubit.dart';
import '../bloc/experience_state.dart';
import '../../domain/entities/experience_entity.dart';
import '../../data/models/experience_model.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({super.key});

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final state = context.read<ExperienceCubit>().state;
      if (state is ExperienceInitial || state is ExperienceError) {
        context.read<ExperienceCubit>().fetchExperiences();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final expState = context.read<ExperienceCubit>().state;
          if (expState is ExperienceInitial || expState is ExperienceError) {
            context.read<ExperienceCubit>().fetchExperiences();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Experience',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your career history and timeline accomplishments.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool isHovered = false;
                      return MouseRegion(
                        onEnter: (_) => setState(() => isHovered = true),
                        onExit: (_) => setState(() => isHovered = false),
                        child: AnimatedScale(
                          scale: isHovered ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showExperienceForm(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Experience'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Content Section
              Expanded(
                child: BlocBuilder<ExperienceCubit, ExperienceState>(
                  builder: (context, state) {
                    if (state is ExperienceLoading) {
                      return _buildShimmerLoading();
                    } else if (state is ExperienceError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is ExperienceLoaded) {
                      if (state.experiences.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.experiences.length,
                          itemBuilder: (context, index) {
                            final exp = state.experiences[index];
                            final isFirst = index == 0;
                            final isLast = index == state.experiences.length - 1;
                            return _buildTimelineItem(exp, isFirst, isLast, context);
                          },
                        ),
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

  Widget _buildTimelineItem(Experience exp, bool isFirst, bool isLast, BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator column
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: isFirst ? Colors.transparent : Colors.white12,
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.white12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Experience details container
          Expanded(
            child: StatefulBuilder(
              builder: (context, setState) {
                bool isHovered = false;
                return MouseRegion(
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isHovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.015),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHovered ? AppColors.primary.withOpacity(0.4) : Colors.white12,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo (or placeholder icon)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: exp.logoUrl != null && exp.logoUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    exp.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.business_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                        ),
                        const SizedBox(width: 20),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.role,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            exp.company,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '•',
                                            style: TextStyle(color: Colors.white24),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            exp.location,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Edit/Delete buttons (visible on hover)
                                  AnimatedOpacity(
                                    opacity: isHovered ? 1.0 : 0.2,
                                    duration: const Duration(milliseconds: 200),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20),
                                          color: AppColors.primary,
                                          onPressed: () => _showExperienceForm(context, exp),
                                          tooltip: 'Edit Experience',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          color: Colors.redAccent,
                                          onPressed: () => _confirmDelete(context, exp),
                                          tooltip: 'Delete Experience',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Date Range badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  '${exp.startDate} — ${exp.endDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Description points
                              ...exp.description.split('\n').where((line) => line.trim().isNotEmpty).map((bullet) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6.0, right: 10.0),
                                        child: Icon(Icons.lens, size: 6, color: AppColors.primary),
                                      ),
                                      Expanded(
                                        child: Text(
                                          bullet.replaceAll(RegExp(r'^-\s*'), ''), // Strip markdown bullet chars if any
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.15),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                const CircleAvatar(radius: 8, backgroundColor: Colors.white),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_edu_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No work experience found',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click "Add Experience" to create your first career timeline milestone.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Experience exp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Experience?'),
        content: Text(
          'Are you sure you want to delete your experience at "${exp.company}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ExperienceCubit>().deleteExperience(exp.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExperienceForm(BuildContext context, [Experience? exp]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BlocProvider.value(
          value: context.read<ExperienceCubit>(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(32),
                child: ExperienceFormView(exp: exp),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExperienceFormView extends StatefulWidget {
  final Experience? exp;

  const ExperienceFormView({super.key, this.exp});

  @override
  State<ExperienceFormView> createState() => _ExperienceFormViewState();
}

class _ExperienceFormViewState extends State<ExperienceFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _logoUrlController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.exp?.company ?? '');
    _roleController = TextEditingController(text: widget.exp?.role ?? '');
    _startDateController = TextEditingController(text: widget.exp?.startDate ?? '');
    _endDateController = TextEditingController(text: widget.exp?.endDate ?? 'Present');
    _descriptionController = TextEditingController(text: widget.exp?.description ?? '');
    _locationController = TextEditingController(text: widget.exp?.location ?? 'Remote');
    _logoUrlController = TextEditingController(text: widget.exp?.logoUrl ?? '');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newExp = ExperienceModel(
        id: widget.exp?.id ?? '',
        company: _companyController.text.trim(),
        role: _roleController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isNotEmpty ? _logoUrlController.text.trim() : null,
      );

      if (widget.exp == null) {
        context.read<ExperienceCubit>().addExperience(newExp);
      } else {
        context.read<ExperienceCubit>().updateExperience(newExp);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
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
                          widget.exp == null ? 'Add Work Experience' : 'Edit Work Experience',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 32),

                    Row(
                      children: [
                        // Role / Position
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Role / Position *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _roleController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. Senior Flutter Developer'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Role is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Company
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Company / Organization *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _companyController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. Google'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Company is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _startDateController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. Jan 2023'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Start Date is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // End Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _endDateController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. Dec 2024 or Present'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'End Date is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Location', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _locationController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. Remote or San Francisco, CA'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Logo URL
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Company Logo URL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _logoUrlController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('e.g. https://domain.com/logo.png'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description Points
                    const Text(
                      'Responsibilities / Description * (One bullet point per line)',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white, height: 1.5),
                      maxLines: 6,
                      decoration: _inputDecoration(
                        'Designed Clean Architecture structure.\nIntegrated third-party APIs.\nLed team of developers.',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(widget.exp == null ? 'Create Milestone' : 'Save Changes'),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}
