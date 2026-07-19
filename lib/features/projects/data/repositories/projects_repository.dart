import 'package:dartz/dartz.dart';
import '../datasources/projects_remote_data_source.dart';
import '../models/project_model.dart';

class ProjectsRepository {
  final ProjectsRemoteDataSource remoteDataSource;

  ProjectsRepository({required this.remoteDataSource});

  Future<Either<String, List<ProjectModel>>> getProjects() async {
    try {
      final projects = await remoteDataSource.getProjects();
      return Right(projects);
    } catch (e) {
      return Left('Failed to fetch projects: $e');
    }
  }

  Future<Either<String, void>> addProject(ProjectModel project) async {
    try {
      await remoteDataSource.addProject(project);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add project: $e');
    }
  }

  Future<Either<String, void>> updateProject(ProjectModel project) async {
    try {
      await remoteDataSource.updateProject(project);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update project: $e');
    }
  }

  Future<Either<String, void>> deleteProject(String id) async {
    try {
      await remoteDataSource.deleteProject(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete project: $e');
    }
  }

  Future<Either<String, void>> reorderProjects(
      List<String> orderedIds) async {
    try {
      await remoteDataSource.reorderProjects(orderedIds);
      return const Right(null);
    } catch (e) {
      return Left('Failed to reorder projects: $e');
    }
  }
}
