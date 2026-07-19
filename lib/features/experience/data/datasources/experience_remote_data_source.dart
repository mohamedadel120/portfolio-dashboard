import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';

class ExperienceRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExperienceRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ExperienceModel>> getExperiences() async {
    final snapshot = await _firestore.collection('experiences').get();
    return snapshot.docs
        .map((doc) => ExperienceModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addExperience(ExperienceModel experience) async {
    await _firestore.collection('experiences').add(experience.toJson());
  }

  Future<void> updateExperience(ExperienceModel experience) async {
    await _firestore
        .collection('experiences')
        .doc(experience.id)
        .update(experience.toJson());
  }

  Future<void> deleteExperience(String id) async {
    await _firestore.collection('experiences').doc(id).delete();
  }
}
