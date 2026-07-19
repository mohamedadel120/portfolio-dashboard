import '../../domain/entities/testimonial_entity.dart';

class TestimonialModel extends Testimonial {
  const TestimonialModel({
    required super.id,
    required super.name,
    required super.role,
    required super.company,
    required super.opinion,
    required super.rating,
    super.imageUrl,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json, String id) {
    final name = (json['name'] ?? json['clientName'] ?? '').toString();
    final role = (json['role'] ?? json['position'] ?? json['title'] ?? '').toString();
    final company = (json['company'] ?? json['organization'] ?? '').toString();
    final opinion = (json['opinion'] ?? json['review'] ?? json['comment'] ?? json['feedback'] ?? '').toString();

    int rating = 5;
    final rawRating = json['rating'] ?? json['stars'];
    if (rawRating != null) {
      if (rawRating is num) {
        rating = rawRating.toInt();
      } else {
        rating = int.tryParse(rawRating.toString()) ?? 5;
      }
    }
    rating = rating.clamp(1, 5);

    final imageUrl = json['imageUrl']?.toString() ?? json['photo']?.toString() ?? json['avatar']?.toString();

    return TestimonialModel(
      id: id,
      name: name,
      role: role,
      company: company,
      opinion: opinion,
      rating: rating,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'company': company,
      'opinion': opinion,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}
