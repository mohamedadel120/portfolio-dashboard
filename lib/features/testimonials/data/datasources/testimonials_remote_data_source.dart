import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/testimonial_model.dart';

class TestimonialsRemoteDataSource {
  final FirebaseFirestore _firestore;

  TestimonialsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<TestimonialModel>> getTestimonials() async {
    final snapshot = await _firestore.collection('testimonials').get();
    return snapshot.docs
        .map((doc) => TestimonialModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addTestimonial(TestimonialModel testimonial) async {
    await _firestore.collection('testimonials').add(testimonial.toJson());
  }

  Future<void> updateTestimonial(TestimonialModel testimonial) async {
    await _firestore
        .collection('testimonials')
        .doc(testimonial.id)
        .update(testimonial.toJson());
  }

  Future<void> deleteTestimonial(String id) async {
    await _firestore.collection('testimonials').doc(id).delete();
  }
}
