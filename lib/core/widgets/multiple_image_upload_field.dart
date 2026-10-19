import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';

class MultipleImageUploadField extends StatefulWidget {
  final String label;
  final ValueNotifier<List<String>> imagesNotifier;
  final String storagePath;

  const MultipleImageUploadField({
    super.key,
    required this.label,
    required this.imagesNotifier,
    required this.storagePath,
  });

  @override
  State<MultipleImageUploadField> createState() => _MultipleImageUploadFieldState();
}

class _MultipleImageUploadFieldState extends State<MultipleImageUploadField> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isHoveringDropzone = false;
  int? _hoveredImageIndex;

  Future<void> _pickAndUploadImages() async {
    if (demoMode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Uploads are turned off in demo mode.')));
      return;
    }
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 60,
        maxWidth: 1920,
      );
      if (images.isEmpty) return;

      setState(() {
        _isUploading = true;
      });

      int totalImages = images.length;
      int completedImages = 0;

      for (var image in images) {
        final String base64Image = base64Encode(await image.readAsBytes());
        
        final response = await http.post(
          Uri.parse('https://api.imgbb.com/1/upload'),
          body: {
            'key': '52f5f6dc0c6ebb3b06078fe0f36b146d',
            'image': base64Image,
          },
        );
        
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final downloadUrl = responseData['data']['url'];
          
          // Add to list
          final currentList = List<String>.from(widget.imagesNotifier.value);
          currentList.add(downloadUrl);
          widget.imagesNotifier.value = currentList;
        } else {
          throw Exception(responseData['error']['message'] ?? 'Failed to upload image');
        }
        
        completedImages++;
        setState(() {
          _uploadProgress = completedImages / totalImages;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _removeImage(int index) {
    final currentList = List<String>.from(widget.imagesNotifier.value);
    currentList.removeAt(index);
    widget.imagesNotifier.value = currentList;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: widget.imagesNotifier,
      builder: (context, images, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.label} (${images.length})',
                    style: const TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadImages,
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: const Text('Add images'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (images.isEmpty && !_isUploading)
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringDropzone = true),
                onExit: (_) => setState(() => _isHoveringDropzone = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _pickAndUploadImages,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isHoveringDropzone 
                          ? AppColors.primary.withValues(alpha: 0.08) 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isHoveringDropzone
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.borderStrong,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.collections_outlined,
                            size: 32,
                            color: _isHoveringDropzone ? AppColors.primary : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: _isHoveringDropzone ? AppColors.ink : AppColors.textTertiary,
                              fontWeight: _isHoveringDropzone ? FontWeight.w600 : FontWeight.normal,
                            ),
                            child: const Text('Click to upload gallery screenshots'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...images.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String url = entry.value;
                      bool isHovered = _hoveredImageIndex == idx;
                      
                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredImageIndex = idx),
                        onExit: (_) => setState(() => _hoveredImageIndex = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 100,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isHovered ? AppColors.borderStrong : AppColors.border,
                            ),
                            boxShadow: isHovered 
                                ? [
                                    BoxShadow(
                                      color: AppColors.ink.withValues(alpha: 0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (url.startsWith('http'))
                                  Image.network(url, fit: BoxFit.cover)
                                else
                                  const Center(
                                    child: Text('Local\nAsset', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textTertiary))
                                  ),
                                
                                // Overlay
                                AnimatedOpacity(
                                  opacity: isHovered ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    color: AppColors.ink.withValues(alpha: 0.18),
                                  ),
                                ),
                                
                                // Delete button: always visible (works on touch)
                                Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Material(
                                      color: AppColors.surface,
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        onTap: () => _removeImage(idx),
                                        customBorder: const CircleBorder(),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_isUploading)
                      Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                            const SizedBox(height: 12),
                            Text(
                              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
