import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_info_cubit.dart';
import '../bloc/profile_info_state.dart';
import '../../domain/entities/profile_info_entity.dart';
import '../../data/models/profile_info_model.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Info',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage the hero/about content and tech stack shown on your portfolio.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 32),
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
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
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
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile info saved')),
      );
    }
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

  Widget _label(String text) => Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. 3+ Years Experience'),
              ),
              const SizedBox(height: 20),

              _label('Hero Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. Building Scalable Cross-Platform Mobile Applications'),
              ),
              const SizedBox(height: 20),

              _label('Professional Summary'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _summaryController,
                style: const TextStyle(color: Colors.white, height: 1.5),
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
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('e.g. https://drive.google.com/...'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 24),

              _label('Tech Stack'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _techStack.map((tech) {
                  return Chip(
                    label: Text(tech, style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('e.g. Flutter'),
                      onFieldSubmitted: (_) => _addTech(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addTech,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: widget.isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: widget.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
