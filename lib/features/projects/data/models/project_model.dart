import 'package:flutter/material.dart';
import '../../domain/entities/project_entity.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.tech,
    required super.color,
    required super.downloads,
    super.imageUrl,
    super.logoUrl,
    super.galleryImages,
    super.androidStoreUrl,
    super.iosStoreUrl,
    super.videoUrl,
    super.sortOrder = 0,
  });

  factory ProjectModel.fromEntity(Project entity) => ProjectModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        tech: entity.tech,
        color: entity.color,
        downloads: entity.downloads,
        imageUrl: entity.imageUrl,
        logoUrl: entity.logoUrl,
        galleryImages: entity.galleryImages,
        androidStoreUrl: entity.androidStoreUrl,
        iosStoreUrl: entity.iosStoreUrl,
        videoUrl: entity.videoUrl,
        sortOrder: entity.sortOrder,
      );

  factory ProjectModel.fromJson(Map<String, dynamic> json, String id) {
    return ProjectModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tech: List<String>.from(json['tech'] ?? []),
      color: Color(json['color'] ?? 0xFF000000),
      downloads: json['downloads'] ?? '',
      imageUrl: json['imageUrl'],
      logoUrl: json['logoUrl'],
      galleryImages: json['galleryImages'] != null
          ? List<String>.from(json['galleryImages'])
          : null,
      androidStoreUrl: json['androidStoreUrl'],
      iosStoreUrl: json['iosStoreUrl'],
      videoUrl: json['videoUrl'],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tech': tech,
      'color': color.toARGB32(),
      'downloads': downloads,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'galleryImages': galleryImages,
      'androidStoreUrl': androidStoreUrl,
      'iosStoreUrl': iosStoreUrl,
      'videoUrl': videoUrl,
      'sortOrder': sortOrder,
    };
  }
}
