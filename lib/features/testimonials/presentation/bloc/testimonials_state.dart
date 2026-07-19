import 'package:equatable/equatable.dart';
import '../../domain/entities/testimonial_entity.dart';

abstract class TestimonialsState extends Equatable {
  const TestimonialsState();

  @override
  List<Object?> get props => [];
}

class TestimonialsInitial extends TestimonialsState {}

class TestimonialsLoading extends TestimonialsState {}

class TestimonialsLoaded extends TestimonialsState {
  final List<Testimonial> testimonials;

  const TestimonialsLoaded({required this.testimonials});

  @override
  List<Object?> get props => [testimonials];
}

class TestimonialsError extends TestimonialsState {
  final String message;

  const TestimonialsError({required this.message});

  @override
  List<Object?> get props => [message];
}
