import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ProjectModel>> getProjects() async {
    final snapshot = await _firestore.collection('projects').get();
    final projects = snapshot.docs
        .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
        .toList();
    // Sort client-side so documents without sortOrder field are still returned
    projects.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return projects;
  }

  Future<void> addProject(ProjectModel project) async {
    await _firestore.collection('projects').add(project.toJson());
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await _firestore.collection('projects').doc(id).delete();
  }

  /// Batch-writes sortOrder for every project in orderedIds.
  Future<void> reorderProjects(List<String> orderedIds) async {
    final batch = _firestore.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(
        _firestore.collection('projects').doc(orderedIds[i]),
        {'sortOrder': i},
      );
    }
    await batch.commit();
  }
}
