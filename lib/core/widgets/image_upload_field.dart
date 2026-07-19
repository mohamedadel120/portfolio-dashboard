import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_dashboard/core/constants/app_colors.dart';

class ImageUploadField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String storagePath;

  const ImageUploadField({
    super.key,
    required this.label,
    required this.controller,
    required this.storagePath,
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isHovering = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1920,
      );
      if (image == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Simulate progress since HTTP post doesn't give precise upload stream easily on simple requests
      setState(() {
        _uploadProgress = 0.5;
      });

      final String base64Image = base64Encode(await image.readAsBytes());

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {'key': '52f5f6dc0c6ebb3b06078fe0f36b146d', 'image': base64Image},
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        final downloadUrl = responseData['data']['url'];
        widget.controller.text = downloadUrl;
      } else {
        throw Exception(
          responseData['error']['message'] ?? 'Failed to upload image',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeImage() {
    widget.controller.clear();
    setState(() {}); // Trigger rebuild
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        splashRadius: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a ValueListenableBuilder or just rely on state changes
    // to detect when the controller updates. But since the controller
    // is external, we will just listen to it directly.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final hasImage = widget.controller.text.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              cursor: (!hasImage && !_isUploading)
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: (!hasImage && !_isUploading)
                    ? _pickAndUploadImage
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isHovering
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasImage
                          ? AppColors.primary.withOpacity(
                              _isHovering ? 0.8 : 0.5,
                            )
                          : (_isHovering ? Colors.white38 : Colors.white12),
                      width: hasImage ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image Background with scale animation
                        if (hasImage &&
                            widget.controller.text.startsWith('http'))
                          AnimatedScale(
                            scale: _isHovering ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: Image.network(
                              widget.controller.text,
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Dark gradient overlay when hovering on image
                        if (hasImage)
                          AnimatedOpacity(
                            opacity: _isHovering ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                  stops: [0.0, 0.4],
                                ),
                              ),
                            ),
                          ),

                        // Error state for local paths
                        if (hasImage &&
                            !widget.controller.text.startsWith('http'))
                          const Center(
                            child: Text(
                              'Local asset path saved.\nPlease upload a new image.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),

                        // Empty State (Upload prompt)
                        if (!hasImage && !_isUploading)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _isHovering
                                      ? AppColors.primary.withOpacity(0.15)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: _isHovering
                                      ? AppColors.primary
                                      : Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovering
                                      ? Colors.white
                                      : Colors.white54,
                                  fontWeight: _isHovering
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                child: const Text('Click to browse and upload'),
                              ),
                            ],
                          ),

                        // Uploading State
                        if (_isUploading)
                          Container(
                            color: Colors.black87,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Actions (Edit/Delete) overlay
                        if (hasImage && !_isUploading)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: AnimatedOpacity(
                              opacity: _isHovering ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Row(
                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit_rounded,
                                    color: Colors.white,
                                    onPressed: _pickAndUploadImage,
                                    tooltip: 'Replace Image',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.delete_rounded,
                                    color: Colors.redAccent,
                                    onPressed: _removeImage,
                                    tooltip: 'Remove Image',
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
