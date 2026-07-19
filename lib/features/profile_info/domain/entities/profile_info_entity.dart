import 'package:equatable/equatable.dart';

class ProfileInfo extends Equatable {
  final String name;
  final String title;
  final String subtitle;
  final String description;
  final String professionalSummary;
  final String email;
  final String phone;
  final String location;
  final String cvUrl;
  final List<String> techStack;

  const ProfileInfo({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.professionalSummary,
    required this.email,
    required this.phone,
    required this.location,
    required this.cvUrl,
    required this.techStack,
  });

  @override
  List<Object?> get props => [
        name,
        title,
        subtitle,
        description,
        professionalSummary,
        email,
        phone,
        location,
        cvUrl,
        techStack,
      ];
}
