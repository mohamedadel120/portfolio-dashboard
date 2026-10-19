import 'package:flutter/material.dart';
import '../models/project_model.dart';
import 'projects_remote_data_source.dart';

/// In-memory projects for demo mode (`--dart-define=DEMO=true`) and tests.
/// Never touches Firestore.
class MockProjectsRemoteDataSource implements ProjectsRemoteDataSource {
  final List<ProjectModel> _mockProjects = [
    const ProjectModel(
      id: 'demo-gomla',
      title: 'Gomla Mobile App',
      description:
          'A wholesale marketplace app that connects sellers and shop owners, '
          'with a seller dashboard, order tracking and payments.',
      tech: ['Flutter', 'Bloc', 'Firebase', 'REST'],
      color: Color(0xFFE4572E),
      downloads: '10,000+',
      androidStoreUrl: 'https://play.google.com/store/apps/details?id=demo',
      featured: true,
      highlight: 'Demo highlight: one short sentence about the result.',
      problem: 'Demo text: what was broken or missing before this app.',
      role: 'Demo text: what I owned, from architecture to release.',
      outcome: 'Demo text: what changed after launch.',
      sortOrder: 0,
    ),
    const ProjectModel(
      id: 'demo-stock',
      title: 'Stock Mobile App',
      description:
          'Inventory and stock management for small businesses, with offline '
          'support and barcode scanning.',
      tech: ['Flutter', 'Clean Architecture', 'SQLite'],
      color: Color(0xFF2563EB),
      downloads: '10,000+',
      androidStoreUrl: 'https://play.google.com/store/apps/details?id=demo2',
      iosStoreUrl: 'https://apps.apple.com/app/id000000',
      sortOrder: 1,
    ),
    const ProjectModel(
      id: 'demo-drugza',
      title: 'DrugZa - TagPharma',
      description:
          'A pharmacy ordering app with prescription upload and delivery '
          'tracking.',
      tech: ['Flutter', 'Cubit', 'Google Maps'],
      color: Color(0xFF0F9D58),
      downloads: 'Active Development',
      slug: 'drugza',
      sortOrder: 2,
    ),
  ];

  @override
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate network
    return List.from(_mockProjects);
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockProjects.add(ProjectModel.fromEntity(project));
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _mockProjects[index] = project;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockProjects.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> reorderProjects(List<String> orderedIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < orderedIds.length; i++) {
      final idx = _mockProjects.indexWhere((p) => p.id == orderedIds[i]);
      if (idx != -1) {
        final p = _mockProjects[idx];
        _mockProjects[idx] = ProjectModel(
          id: p.id,
          title: p.title,
          description: p.description,
          tech: p.tech,
          color: p.color,
          downloads: p.downloads,
          imageUrl: p.imageUrl,
          logoUrl: p.logoUrl,
          galleryImages: p.galleryImages,
          androidStoreUrl: p.androidStoreUrl,
          iosStoreUrl: p.iosStoreUrl,
          videoUrl: p.videoUrl,
          sortOrder: i,
          featured: p.featured,
          highlight: p.highlight,
          problem: p.problem,
          role: p.role,
          outcome: p.outcome,
          slug: p.slug,
        );
      }
    }
  }
}
