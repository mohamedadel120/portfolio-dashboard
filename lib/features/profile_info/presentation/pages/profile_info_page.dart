import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:admin_dashboard/core/widgets/unsaved_changes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_info_cubit.dart';
import '../bloc/profile_info_state.dart';
import '../../domain/entities/profile_info_entity.dart';
import '../../data/models/profile_info_model.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  /// True while the form holds edits that are not saved; the router reads it
  /// before leaving the page (see app_router.dart, onExit).
  static final unsavedChanges = ValueNotifier<bool>(false);

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (demoMode || authState is Authenticated) {
      final state = context.read<ProfileInfoCubit>().state;
      if (state is ProfileInfoInitial || state is ProfileInfoError) {
        context.read<ProfileInfoCubit>().fetchProfileInfo();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final pState = context.read<ProfileInfoCubit>().state;
          if (pState is ProfileInfoInitial || pState is ProfileInfoError) {
            context.read<ProfileInfoCubit>().fetchProfileInfo();
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
              const PageHeader(
                title: 'Profile info',
                subtitle: 'The hero, about text, contact details and tech stack on the site.',
              ),
              const SizedBox(height: 28),
              Expanded(
                child: BlocConsumer<ProfileInfoCubit, ProfileInfoState>(
                  listener: (context, state) {
                    if (state is ProfileInfoLoaded && !state.isSaving) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  },
                  builder: (context, state) {
                    if (state is ProfileInfoLoading) {
                      return _buildShimmerLoading();
                    } else if (state is ProfileInfoError) {
                      return EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load profile info',
                        message: state.message,
                        isError: true,
                        actionLabel: 'Retry',
                        actionIcon: Icons.refresh_rounded,
                        onAction: () =>
                            context.read<ProfileInfoCubit>().fetchProfileInfo(),
                      );
                    } else if (state is ProfileInfoLoaded) {
                      return _ProfileInfoForm(profile: state.profile, isSaving: state.isSaving);
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

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ProfileInfoForm extends StatefulWidget {
  final ProfileInfo profile;
  final bool isSaving;

  const _ProfileInfoForm({required this.profile, required this.isSaving});

  @override
  State<_ProfileInfoForm> createState() => _ProfileInfoFormState();
}

class _ProfileInfoFormState extends State<_ProfileInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _summaryController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _cvUrlController;
  late TextEditingController _newTechController;
  late List<String> _techStack;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title);
    _subtitleController = TextEditingController(text: widget.profile.subtitle);
    _descriptionController = TextEditingController(text: widget.profile.description);
    _summaryController = TextEditingController(text: widget.profile.professionalSummary);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _locationController = TextEditingController(text: widget.profile.location);
    _cvUrlController = TextEditingController(text: widget.profile.cvUrl);
    _newTechController = TextEditingController();
    _techStack = List<String>.from(widget.profile.techStack);
    _saved = _snapshot();
  }

  /// The values as last saved (or loaded), to tell whether there are edits.
  late String _saved;

  String _snapshot() => formSnapshot([
        _nameController, _titleController, _subtitleController, _descriptionController, _summaryController,
        _emailController, _phoneController, _locationController, _cvUrlController, _techStack,
      ]);

  bool get _dirty => _snapshot() != _saved;

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _cvUrlController.dispose();
    _newTechController.dispose();
    ProfileInfoPage.unsavedChanges.value = false;
    super.dispose();
  }

  void _addTech() {
    final value = _newTechController.text.trim();
    if (value.isEmpty || _techStack.contains(value)) return;
    setState(() {
      _techStack.add(value);
      _newTechController.clear();
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updated = ProfileInfoModel(
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        description: _descriptionController.text.trim(),
        professionalSummary: _summaryController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        cvUrl: _cvUrlController.text.trim(),
        techStack: _techStack,
      );
      context.read<ProfileInfoCubit>().updateProfileInfo(updated);
      setState(() => _saved = _snapshot());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile info saved')),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    // Colours, borders and radius come from the app's input theme.
    return InputDecoration(hintText: hint);
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500));

  @override
  Widget build(BuildContext context) {
    final dirty = _dirty;
    ProfileInfoPage.unsavedChanges.value = dirty;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Form(
        key: _formKey,
        // Rebuild on every edit so the footer can say "Unsaved changes".
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            Expanded(child: _fields()),
            const SizedBox(height: 20),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            // Always visible, however long the form scrolls.
            Row(
              children: [
                if (dirty) ...[
                  const Icon(Icons.circle, size: 8, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Text('Unsaved changes', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                ] else
                  const Text('All changes saved', style: TextStyle(color: AppColors.textTertiary, fontSize: 13.5)),
                const Spacer(),
                AppButton(
                  label: 'Save changes',
                  icon: Icons.check_rounded,
                  isLoading: widget.isSaving,
                  onPressed: widget.isSaving || !dirty ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fields() {
    return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Full Name *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. Mohamed Adel'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Title *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. Flutter Developer'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _label('Subtitle'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subtitleController,
                style: const TextStyle(color: AppColors.ink),
                decoration: _inputDecoration('e.g. 3+ Years Experience'),
              ),
              const SizedBox(height: 20),

              _label('Hero Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.ink),
                decoration: _inputDecoration('e.g. Building Scalable Cross-Platform Mobile Applications'),
              ),
              const SizedBox(height: 20),

              _label('Professional Summary'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _summaryController,
                style: const TextStyle(color: AppColors.ink, height: 1.5),
                maxLines: 5,
                decoration: _inputDecoration('Full about-me summary shown on the site.'),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. you@example.com'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Phone'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. +20 100 000 0000'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Location'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. Cairo, Egypt'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('CV URL'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cvUrlController,
                          style: const TextStyle(color: AppColors.ink),
                          decoration: _inputDecoration('e.g. https://drive.google.com/...'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 24),

              _label('Tech Stack'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _techStack.map((tech) {
                  return Chip(
                    label: Text(tech,
                        style: AppFonts.monoStyle(
                            fontSize: 12.5, color: AppColors.ink)),
                    backgroundColor: AppColors.background,
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                    deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                    onDeleted: () => setState(() => _techStack.remove(tech)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newTechController,
                      style: const TextStyle(color: AppColors.ink),
                      decoration: _inputDecoration('e.g. Flutter'),
                      onFieldSubmitted: (_) => _addTech(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Add',
                    icon: Icons.add_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: _addTech,
                  ),
                ],
              ),
            ],
          ),
        );
  }
}
