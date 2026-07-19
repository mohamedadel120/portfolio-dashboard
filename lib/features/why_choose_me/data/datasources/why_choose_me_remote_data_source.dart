import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/why_choose_me_model.dart';

class WhyChooseMeRemoteDataSource {
  final FirebaseFirestore _firestore;

  WhyChooseMeRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<WhyChooseMeModel>> getItems() async {
    final snapshot = await _firestore.collection('why_choose_me').get();
    return snapshot.docs
        .map((doc) => WhyChooseMeModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addItem(WhyChooseMeModel item) async {
    await _firestore.collection('why_choose_me').add(item.toJson());
  }

  Future<void> updateItem(WhyChooseMeModel item) async {
    await _firestore
        .collection('why_choose_me')
        .doc(item.id)
        .update(item.toJson());
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection('why_choose_me').doc(id).delete();
  }
}
