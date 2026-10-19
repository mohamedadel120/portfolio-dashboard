import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
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
    if (demoMode || authState is Authenticated) {
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
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Experience',
                subtitle: 'Your career history, shown as a timeline on the site.',
                actions: [
                  AppButton(
                    label: 'Add experience',
                    icon: Icons.add_rounded,
                    onPressed: () => _showExperienceForm(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Content Section
              Expanded(
                child: BlocBuilder<ExperienceCubit, ExperienceState>(
                  builder: (context, state) {
                    if (state is ExperienceLoading) {
                      return _buildShimmerLoading();
                    } else if (state is ExperienceError) {
                      return EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load experience',
                        message: state.message,
                        isError: true,
                        actionLabel: 'Retry',
                        actionIcon: Icons.refresh_rounded,
                        onAction: () =>
                            context.read<ExperienceCubit>().fetchExperiences(),
                      );
                    } else if (state is ExperienceLoaded) {
                      if (state.experiences.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Container(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.card,
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
                color: isFirst ? Colors.transparent : AppColors.border,
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : AppColors.border,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Experience details container
          Expanded(
            child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo (or placeholder icon)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: exp.logoUrl != null && exp.logoUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    exp.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business_rounded,
                                      color: AppColors.textTertiary,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.business_rounded,
                                  color: AppColors.textTertiary,
                                  size: 24,
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
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            exp.company,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              color: AppColors.ink,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '•',
                                            style: TextStyle(color: AppColors.textTertiary),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            exp.location,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Edit/Delete buttons (visible on hover)
                                  Row(
                                    children: [
                                      IconActionButton(
                                        icon: Icons.edit_outlined,
                                        tooltip: 'Edit',
                                        onPressed: () => _showExperienceForm(context, exp),
                                      ),
                                      const SizedBox(width: 6),
                                      IconActionButton(
                                        icon: Icons.delete_outline_rounded,
                                        tooltip: 'Delete',
                                        destructive: true,
                                        onPressed: () => _confirmDelete(context, exp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Date Range badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '${exp.startDate} — ${exp.endDate}',
                                  style: AppFonts.monoStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
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
                                        child: Icon(Icons.lens, size: 5, color: AppColors.textTertiary),
                                      ),
                                      Expanded(
                                        child: Text(
                                          bullet.replaceAll(RegExp(r'^-\s*'), ''), // Strip markdown bullet chars if any
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: AppColors.textSecondary,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                const CircleAvatar(radius: 8, backgroundColor: AppColors.surfaceLight),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
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
    return EmptyState(
      icon: Icons.history_edu_outlined,
      title: 'No experience yet',
      message: "Add your first role and it will show on the site's timeline.",
      actionLabel: 'Add experience',
      actionIcon: Icons.add_rounded,
      onAction: () => _showExperienceForm(context),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Experience exp) async {
    final cubit = context.read<ExperienceCubit>();
    final ok = await confirmDelete(context,
        title: 'Delete experience?', itemName: exp.company);
    if (ok) cubit.deleteExperience(exp.id);
  }

  void _showExperienceForm(BuildContext context, [Experience? exp]) {
    final cubit = context.read<ExperienceCubit>();
    showAppDialog(
      context,
      (_) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ExperienceFormView(exp: exp),
        ),
      ),
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
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                          widget.exp == null ? 'Add Work Experience' : 'Edit Work Experience',
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 32),

                    Row(
                      children: [
                        // Role / Position
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Role / Position *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _roleController,
                                style: const TextStyle(color: AppColors.ink),
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
                              const Text('Company / Organization *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _companyController,
                                style: const TextStyle(color: AppColors.ink),
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
                              const Text('Start Date *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _startDateController,
                                style: const TextStyle(color: AppColors.ink),
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
                              const Text('End Date *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _endDateController,
                                style: const TextStyle(color: AppColors.ink),
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
                              const Text('Location', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _locationController,
                                style: const TextStyle(color: AppColors.ink),
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
                              const Text('Company Logo URL', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _logoUrlController,
                                style: const TextStyle(color: AppColors.ink),
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
                      style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: AppColors.ink, height: 1.5),
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
                        AppButton(
                          label: 'Cancel',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          label: widget.exp == null ? 'Add experience' : 'Save changes',
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    // Colours, borders and radius come from the app's input theme.
    return InputDecoration(hintText: hint);
  }
}
