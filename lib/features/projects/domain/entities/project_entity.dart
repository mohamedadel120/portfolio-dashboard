import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id; // Required for Admin Dashboard (Firestore Doc ID)
  final String title;
  final String description;
  final List<String> tech;
  final Color color;
  final String downloads;
  final String? imageUrl;
  final String? logoUrl;
  final List<String>? galleryImages;
  final String? androidStoreUrl;
  final String? iosStoreUrl;
  final String? videoUrl;
  final int sortOrder;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.tech,
    required this.color,
    required this.downloads,
    this.imageUrl,
    this.logoUrl,
    this.galleryImages,
    this.androidStoreUrl,
    this.iosStoreUrl,
    this.videoUrl,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        tech,
        color,
        downloads,
        imageUrl,
        logoUrl,
        galleryImages,
        androidStoreUrl,
        iosStoreUrl,
        videoUrl,
        sortOrder,
      ];
}
