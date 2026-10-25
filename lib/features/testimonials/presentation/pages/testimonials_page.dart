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
import '../bloc/testimonials_cubit.dart';
import '../bloc/testimonials_state.dart';
import '../../domain/entities/testimonial_entity.dart';
import '../../data/models/testimonial_model.dart';

class TestimonialsPage extends StatefulWidget {
  const TestimonialsPage({super.key});

  @override
  State<TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (demoMode || authState is Authenticated) {
      final state = context.read<TestimonialsCubit>().state;
      if (state is TestimonialsInitial || state is TestimonialsError) {
        context.read<TestimonialsCubit>().fetchTestimonials();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final tState = context.read<TestimonialsCubit>().state;
          if (tState is TestimonialsInitial || tState is TestimonialsError) {
            context.read<TestimonialsCubit>().fetchTestimonials();
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
                title: 'Testimonials',
                subtitle: 'Client reviews shown on the site.',
                actions: [
                  AppButton(
                    label: 'Add testimonial',
                    icon: Icons.add_rounded,
                    onPressed: () => _showTestimonialForm(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: BlocBuilder<TestimonialsCubit, TestimonialsState>(
                  builder: (context, state) {
                    if (state is TestimonialsLoading) {
                      return _buildShimmerLoading();
                    } else if (state is TestimonialsError) {
                      return EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load testimonials',
                        message: state.message,
                        isError: true,
                        actionLabel: 'Retry',
                        actionIcon: Icons.refresh_rounded,
                        onAction: () => context.read<TestimonialsCubit>().fetchTestimonials(),
                      );
                    } else if (state is TestimonialsLoaded) {
                      if (state.testimonials.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, crossAxisSpacing: 20, mainAxisSpacing: 20, mainAxisExtent: 343,
                          ),
                          itemCount: state.testimonials.length,
                          itemBuilder: (context, index) {
                            return _buildTestimonialCard(state.testimonials[index], context);
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

  Widget _buildTestimonialCard(Testimonial t, BuildContext context) {
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
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage: (t.imageUrl != null && t.imageUrl!.isNotEmpty)
                          ? NetworkImage(t.imageUrl!)
                          : null,
                      child: (t.imageUrl == null || t.imageUrl!.isEmpty)
                          ? Text(
                              t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${t.role} • ${t.company}',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          IconActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit',
                            onPressed: () => _showTestimonialForm(context, t),
                          ),
                          const SizedBox(width: 6),
                          IconActionButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Delete',
                            destructive: true,
                            onPressed: () => _confirmDelete(context, t),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Text(
                    t.opinion,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, crossAxisSpacing: 20, mainAxisSpacing: 20, mainAxisExtent: 343,
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
      icon: Icons.rate_review_outlined,
      title: 'No testimonials yet',
      message: 'Add a client review and it will show on the site.',
      actionLabel: 'Add testimonial',
      actionIcon: Icons.add_rounded,
      onAction: () => _showTestimonialForm(context),
    );
  }

  void _confirmDelete(BuildContext context, Testimonial t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Testimonial?'),
        content: Text(
          'Are you sure you want to delete the testimonial from "${t.name}"? This cannot be undone.',
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
              context.read<TestimonialsCubit>().deleteTestimonial(t.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTestimonialForm(BuildContext context, [Testimonial? testimonial]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.ink.withValues(alpha: 0.32),
      transitionDuration: AppMotion.of(context, AppMotion.slow),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BlocProvider.value(
          value: context.read<TestimonialsCubit>(),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: AppMotion.ease),
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: AppMotion.ease)),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(32),
                child: TestimonialFormView(testimonial: testimonial),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TestimonialFormView extends StatefulWidget {
  final Testimonial? testimonial;

  const TestimonialFormView({super.key, this.testimonial});

  @override
  State<TestimonialFormView> createState() => _TestimonialFormViewState();
}

class _TestimonialFormViewState extends State<TestimonialFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _opinionController;
  late TextEditingController _imageUrlController;
  // No longer edited (the site shows no star ratings); kept so saving an
  // existing testimonial does not change the stored value.
  late final int _rating;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.testimonial?.name ?? '');
    _roleController = TextEditingController(text: widget.testimonial?.role ?? '');
    _companyController = TextEditingController(text: widget.testimonial?.company ?? '');
    _opinionController = TextEditingController(text: widget.testimonial?.opinion ?? '');
    _imageUrlController = TextEditingController(text: widget.testimonial?.imageUrl ?? '');
    _rating = widget.testimonial?.rating ?? 5;
    _initialSnapshot = _snapshot();
  }

  /// Everything the form edits, to tell whether it has unsaved changes.
  late final String _initialSnapshot;

  String _snapshot() => formSnapshot([_nameController, _roleController, _companyController, _opinionController, _imageUrlController, _rating]);

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _opinionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newTestimonial = TestimonialModel(
        id: widget.testimonial?.id ?? '',
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        company: _companyController.text.trim(),
        opinion: _opinionController.text.trim(),
        rating: _rating,
        imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
      );

      if (widget.testimonial == null) {
        context.read<TestimonialsCubit>().addTestimonial(newTestimonial);
      } else {
        context.read<TestimonialsCubit>().updateTestimonial(newTestimonial);
      }
      Navigator.of(context).pop();
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
    );
  }

  @override
  Widget build(BuildContext context) => UnsavedChangesGuard(
        isDirty: () => _snapshot() != _initialSnapshot,
        child: _buildForm(context),
      );

  Widget _buildForm(BuildContext context) {
    return Container(
      width: 700,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.testimonial == null ? 'Add Testimonial' : 'Edit Testimonial',
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

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Name *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: AppColors.ink),
                                decoration: _inputDecoration('e.g. Omar Ali'),
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
                              const Text('Role *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _roleController,
                                style: const TextStyle(color: AppColors.ink),
                                decoration: _inputDecoration('e.g. CEO'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Role is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Company *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _companyController,
                      style: const TextStyle(color: AppColors.ink),
                      decoration: _inputDecoration('e.g. The First-Agency'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Company is required' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text('Image URL (optional)', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: AppColors.ink),
                      decoration: _inputDecoration('e.g. https://domain.com/photo.jpg'),
                    ),
                    const SizedBox(height: 20),

                    const Text('Opinion / Review *', style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _opinionController,
                      style: const TextStyle(color: AppColors.ink, height: 1.5),
                      maxLines: 5,
                      decoration: _inputDecoration('What did the client say about working with you?'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Opinion is required' : null,
                    ),
                    const SizedBox(height: 28),

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
                          label: widget.testimonial == null ? 'Create Testimonial' : 'Save Changes',
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
