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
    super.featured = false,
    super.highlight,
    super.problem,
    super.role,
    super.outcome,
    super.slug,
    super.showcase,
    super.storeListings,
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
        featured: entity.featured,
        highlight: entity.highlight,
        problem: entity.problem,
        role: entity.role,
        outcome: entity.outcome,
        slug: entity.slug,
        showcase: entity.showcase,
        storeListings: entity.storeListings,
      );

  factory ProjectModel.fromJson(Map<String, dynamic> json, String id) {
    return ProjectModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tech: List<String>.from(json['tech'] ?? []),
      color: Color(parseColorValue(json['color'])),
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
      featured: parseFlag(json['featured']),
      highlight: nonBlank(json['highlight']),
      problem: nonBlank(json['problem']),
      role: nonBlank(json['role']),
      outcome: nonBlank(json['outcome']),
      slug: nonBlank(json['slug']),
      showcase: Showcase.fromJson(json['showcase']),
      storeListings: StoreListing.listFromJson(json['storeListings']),
    );
  }

  /// Blank optional text is written as null so the site treats it as absent
  /// (and an `update()` clears a value the owner emptied).
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
      'featured': featured,
      'highlight': nonBlank(highlight),
      'problem': nonBlank(problem),
      'role': nonBlank(role),
      'outcome': nonBlank(outcome),
      'slug': nonBlank(slug),
      'showcase': showcase.toJson(),
      'storeListings': storeListings.isEmpty ? null : [for (final l in storeListings) l.toJson()],
    };
  }

  /// Trimmed text, or null when [value] is not a string or is blank.
  static String? nonBlank(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  /// A real boolean or the strings "true" / "false" (as the site accepts).
  static bool parseFlag(Object? raw) => switch (raw) {
        bool b => b,
        String s => s.trim().toLowerCase() == 'true',
        _ => false,
      };

  /// Accepts an int, `"0xFF00D9FF"`, or a decimal string, like the site.
  static int parseColorValue(Object? raw) {
    const fallback = 0xFF000000;
    if (raw is int) return raw;
    if (raw is String) {
      final text = raw.trim();
      if (text.startsWith('0x') || text.startsWith('0X')) {
        return int.tryParse(text.substring(2), radix: 16) ?? fallback;
      }
      return int.tryParse(text) ?? fallback;
    }
    return fallback;
  }
}
