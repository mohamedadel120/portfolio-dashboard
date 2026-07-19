import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expertise_model.dart';

class ExpertiseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpertiseRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ExpertiseModel>> getExpertise() async {
    final snapshot = await _firestore.collection('expertise').get();
    return snapshot.docs
        .map((doc) => ExpertiseModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addExpertise(ExpertiseModel expertise) async {
    await _firestore.collection('expertise').add(expertise.toJson());
  }

  Future<void> updateExpertise(ExpertiseModel expertise) async {
    await _firestore
        .collection('expertise')
        .doc(expertise.id)
        .update(expertise.toJson());
  }

  Future<void> deleteExpertise(String id) async {
    await _firestore.collection('expertise').doc(id).delete();
  }
}
