import 'package:equatable/equatable.dart';

class Experience extends Equatable {
  final String id;
  final String company;
  final String role;
  final String startDate;
  final String endDate;
  final String description;
  final String location;
  final String? logoUrl;

  const Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.location,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        company,
        role,
        startDate,
        endDate,
        description,
        location,
        logoUrl,
      ];
}
