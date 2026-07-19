import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/why_choose_me_cubit.dart';
import '../bloc/why_choose_me_state.dart';
import '../../domain/entities/why_choose_me_entity.dart';
import '../../data/models/why_choose_me_model.dart';

// Curated icon choices for the picker. Icons are only ever rendered by
// selecting one of these const values (never constructed from a raw
// codePoint at runtime), so the icon font tree-shaker can still strip
// unused glyphs at build time.
const Map<String, IconData> _iconOptions = {
  'Trending Up': Icons.trending_up_rounded,
  'Architecture': Icons.architecture_rounded,
  'Speed': Icons.speed_rounded,
  'Code': Icons.code_rounded,
  'Devices': Icons.devices_rounded,
  'Group': Icons.groups_rounded,
  'Star': Icons.star_rounded,
  'Verified': Icons.verified_rounded,
  'Bolt': Icons.bolt_rounded,
  'Shield': Icons.shield_rounded,
  'Support': Icons.support_agent_rounded,
  'Lightbulb': Icons.lightbulb_rounded,
  'Rocket': Icons.rocket_launch_rounded,
  'Design': Icons.design_services_rounded,
  'Analytics': Icons.analytics_rounded,
  'Schedule': Icons.schedule_rounded,
  'Phone': Icons.phone_android_rounded,
  'People': Icons.people_rounded,
};

IconData _resolveIcon(int codePoint) {
  for (final icon in _iconOptions.values) {
    if (icon.codePoint == codePoint) return icon;
  }
  return Icons.star_rounded;
}

class WhyChooseMePage extends StatefulWidget {
  const WhyChooseMePage({super.key});

  @override
  State<WhyChooseMePage> createState() => _WhyChooseMePageState();
}

class _WhyChooseMePageState extends State<WhyChooseMePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final state = context.read<WhyChooseMeCubit>().state;
      if (state is WhyChooseMeInitial || state is WhyChooseMeError) {
        context.read<WhyChooseMeCubit>().fetchItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final wState = context.read<WhyChooseMeCubit>().state;
          if (wState is WhyChooseMeInitial || wState is WhyChooseMeError) {
            context.read<WhyChooseMeCubit>().fetchItems();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose Me',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage the selling points shown on your portfolio.',
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
                              onPressed: () => _showItemForm(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Point'),
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
              Expanded(
                child: BlocBuilder<WhyChooseMeCubit, WhyChooseMeState>(
                  builder: (context, state) {
                    if (state is WhyChooseMeLoading) {
                      return _buildShimmerLoading();
                    } else if (state is WhyChooseMeError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is WhyChooseMeLoaded) {
                      if (state.items.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.6,
                          ),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            return _buildItemCard(state.items[index], context);
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

  Widget _buildItemCard(WhyChooseMeItem item, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.015),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered ? item.color.withOpacity(0.5) : Colors.white12,
                width: isHovered ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _resolveIcon(item.icon),
                        color: item.color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.2,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.primary,
                            onPressed: () => _showItemForm(context, item),
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Colors.redAccent,
                            onPressed: () => _confirmDelete(context, item),
                            tooltip: 'Delete',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isHovered ? item.color : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    item.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.4),
                    maxLines: 4,
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
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.15),
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.6,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
          const Icon(Icons.stars_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No selling points found',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click "Add Point" to create your first selling point.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WhyChooseMeItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This cannot be undone.',
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
              context.read<WhyChooseMeCubit>().deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showItemForm(BuildContext context, [WhyChooseMeItem? item]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BlocProvider.value(
          value: context.read<WhyChooseMeCubit>(),
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
                child: WhyChooseMeFormView(item: item),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WhyChooseMeFormView extends StatefulWidget {
  final WhyChooseMeItem? item;

  const WhyChooseMeFormView({super.key, this.item});

  @override
  State<WhyChooseMeFormView> createState() => _WhyChooseMeFormViewState();
}

class _WhyChooseMeFormViewState extends State<WhyChooseMeFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _colorController;
  late int _selectedIcon;

  final List<Color> _colorPresets = [
    const Color(0xFF00D9FF),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFF2196F3),
    const Color(0xFFFFEB3B),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _selectedIcon = widget.item?.icon ?? _iconOptions.values.first.codePoint;

    String hexColor = widget.item != null
        ? widget.item!.color.value.toRadixString(16).substring(2).toUpperCase()
        : '00D9FF';
    _colorController = TextEditingController(text: hexColor);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Color itemColor = _colorPresets[0];
      try {
        itemColor = Color(
          int.parse('FF${_colorController.text.replaceAll('#', '')}', radix: 16),
        );
      } catch (_) {}

      final newItem = WhyChooseMeModel(
        id: widget.item?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        color: itemColor,
        icon: _selectedIcon,
      );

      if (widget.item == null) {
        context.read<WhyChooseMeCubit>().addItem(newItem);
      } else {
        context.read<WhyChooseMeCubit>().updateItem(newItem);
      }
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 620,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item == null ? 'Add Selling Point' : 'Edit Selling Point',
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

                    const Text('Title *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('e.g. Proven Track Record'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text('Description *', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white, height: 1.5),
                      maxLines: 4,
                      decoration: _inputDecoration('Why does this make you the right choice?'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text('Icon', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _iconOptions.entries.map((entry) {
                        final isSelected = _selectedIcon == entry.value.codePoint;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = entry.value.codePoint),
                          child: Tooltip(
                            message: entry.key,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.white12,
                                ),
                              ),
                              child: Icon(
                                entry.value,
                                size: 18,
                                color: isSelected ? AppColors.primary : Colors.white60,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text('Display Color (Hex)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixText: '# ',
                              prefixStyle: const TextStyle(color: Colors.white30),
                              hintText: '00D9FF',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
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
                        Wrap(
                          spacing: 8,
                          children: _colorPresets.map((c) {
                            final hexStr = c.value.toRadixString(16).substring(2).toUpperCase();
                            final isSelected = _colorController.text.replaceAll('#', '').toUpperCase() == hexStr;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _colorController.text = hexStr;
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

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
                          child: Text(widget.item == null ? 'Create Point' : 'Save Changes'),
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
