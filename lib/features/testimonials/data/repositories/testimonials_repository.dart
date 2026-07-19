import '../../domain/entities/testimonial_entity.dart';
import '../datasources/testimonials_remote_data_source.dart';
import '../models/testimonial_model.dart';

class TestimonialsRepository {
  final TestimonialsRemoteDataSource _remoteDataSource;

  TestimonialsRepository({required TestimonialsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<List<Testimonial>> getTestimonials() async {
    return await _remoteDataSource.getTestimonials();
  }

  Future<void> addTestimonial(TestimonialModel testimonial) async {
    await _remoteDataSource.addTestimonial(testimonial);
  }

  Future<void> updateTestimonial(TestimonialModel testimonial) async {
    await _remoteDataSource.updateTestimonial(testimonial);
  }

  Future<void> deleteTestimonial(String id) async {
    await _remoteDataSource.deleteTestimonial(id);
  }
}
