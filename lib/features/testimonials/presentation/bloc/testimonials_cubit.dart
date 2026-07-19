import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/testimonials_repository.dart';
import '../../data/models/testimonial_model.dart';
import 'testimonials_state.dart';

class TestimonialsCubit extends Cubit<TestimonialsState> {
  final TestimonialsRepository _repository;

  TestimonialsCubit({required TestimonialsRepository repository})
      : _repository = repository,
        super(TestimonialsInitial());

  Future<void> fetchTestimonials() async {
    emit(TestimonialsLoading());
    try {
      final data = await _repository.getTestimonials();
      emit(TestimonialsLoaded(testimonials: data));
    } catch (e) {
      emit(TestimonialsError(message: e.toString()));
    }
  }

  Future<void> addTestimonial(TestimonialModel testimonial) async {
    try {
      await _repository.addTestimonial(testimonial);
      await fetchTestimonials();
    } catch (e) {
      emit(TestimonialsError(message: e.toString()));
    }
  }

  Future<void> updateTestimonial(TestimonialModel testimonial) async {
    try {
      await _repository.updateTestimonial(testimonial);
      await fetchTestimonials();
    } catch (e) {
      emit(TestimonialsError(message: e.toString()));
    }
  }

  Future<void> deleteTestimonial(String id) async {
    try {
      await _repository.deleteTestimonial(id);
      await fetchTestimonials();
    } catch (e) {
      emit(TestimonialsError(message: e.toString()));
    }
  }
}
