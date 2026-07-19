import 'package:equatable/equatable.dart';

class Testimonial extends Equatable {
  final String id;
  final String name;
  final String role;
  final String company;
  final String opinion;
  final int rating;
  final String? imageUrl;

  const Testimonial({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.opinion,
    required this.rating,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, role, company, opinion, rating, imageUrl];
}
