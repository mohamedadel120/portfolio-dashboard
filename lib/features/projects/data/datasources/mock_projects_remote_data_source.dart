import 'package:flutter/material.dart';
import '../models/project_model.dart';
import 'projects_remote_data_source.dart';

class MockProjectsRemoteDataSource implements ProjectsRemoteDataSource {
  final List<ProjectModel> _mockProjects = [
    const ProjectModel(
      id: '1',
      title: 'E-Commerce App',
      description: 'A full-featured e-commerce application with modern UI.',
      tech: ['Flutter', 'Firebase', 'Stripe'],
      color: Colors.blue,
      downloads: '10k+',
    ),
    const ProjectModel(
      id: '2',
      title: 'Task Manager',
      description: 'A productivity app to manage daily tasks efficiently.',
      tech: ['Flutter', 'SQLite', 'Riverpod'],
      color: Colors.green,
      downloads: '5k+',
    ),
    const ProjectModel(
      id: '3',
      title: 'Admin Dashboard',
      description: 'A sleek dashboard for managing application data.',
      tech: ['Flutter Web', 'GetIt', 'Bloc'],
      color: Colors.purple,
      downloads: '1k+',
    ),
  ];

  @override
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return List.from(_mockProjects);
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProjects.add(project);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _mockProjects[index] = project;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProjects.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> reorderProjects(List<String> orderedIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < orderedIds.length; i++) {
      final idx = _mockProjects.indexWhere((p) => p.id == orderedIds[i]);
      if (idx != -1) {
        final updated = ProjectModel(
          id: _mockProjects[idx].id,
          title: _mockProjects[idx].title,
          description: _mockProjects[idx].description,
          tech: _mockProjects[idx].tech,
          color: _mockProjects[idx].color,
          downloads: _mockProjects[idx].downloads,
          imageUrl: _mockProjects[idx].imageUrl,
          logoUrl: _mockProjects[idx].logoUrl,
          galleryImages: _mockProjects[idx].galleryImages,
          androidStoreUrl: _mockProjects[idx].androidStoreUrl,
          iosStoreUrl: _mockProjects[idx].iosStoreUrl,
          videoUrl: _mockProjects[idx].videoUrl,
          sortOrder: i,
        );
        _mockProjects[idx] = updated;
      }
    }
  }
}
