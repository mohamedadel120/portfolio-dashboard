import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/projects_repository.dart';
import '../../domain/entities/project_entity.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository repository;

  ProjectsCubit({required this.repository}) : super(ProjectsInitial());

  Future<void> fetchProjects() async {
    emit(ProjectsLoading());
    final result = await repository.getProjects();
    result.fold(
      (failure) => emit(ProjectsError(failure)),
      (projects) => emit(ProjectsLoaded(projects)),
    );
  }

  Future<void> addProject(Project project) async {
    emit(ProjectsLoading());
    final result = await repository.addProject(ProjectModel.fromEntity(project));
    result.fold(
      (failure) => emit(ProjectsError(failure)),
      (_) => fetchProjects(),
    );
  }

  Future<void> updateProject(Project project) async {
    emit(ProjectsLoading());
    final result = await repository.updateProject(ProjectModel.fromEntity(project));
    result.fold(
      (failure) => emit(ProjectsError(failure)),
      (_) => fetchProjects(),
    );
  }

  Future<void> deleteProject(String id) async {
    emit(ProjectsLoading());
    final result = await repository.deleteProject(id);
    result.fold(
      (failure) => emit(ProjectsError(failure)),
      (_) => fetchProjects(),
    );
  }

  /// Optimistically reorders the list in-memory, then persists to Firestore.
  Future<void> reorderProjects(
      List<Project> projects, int oldIndex, int newIndex) async {
    final reordered = List<Project>.from(projects);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    // Emit optimistically so the UI snaps immediately
    emit(ProjectsLoaded(reordered.cast()));
    final ids = reordered.map((p) => p.id).toList();
    final result = await repository.reorderProjects(ids);
    result.fold(
      (failure) => emit(ProjectsError(failure)),
      (_) {}, // no-op; local state already correct
    );
  }
}
