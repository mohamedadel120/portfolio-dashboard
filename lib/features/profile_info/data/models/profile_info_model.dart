import '../../domain/entities/profile_info_entity.dart';

class ProfileInfoModel extends ProfileInfo {
  const ProfileInfoModel({
    required super.name,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.professionalSummary,
    required super.email,
    required super.phone,
    required super.location,
    required super.cvUrl,
    required super.techStack,
  });

  factory ProfileInfoModel.fromJson(Map<String, dynamic> mainJson, List<dynamic> techStackItems) {
    return ProfileInfoModel(
      name: (mainJson['name'] ?? '').toString(),
      title: (mainJson['title'] ?? '').toString(),
      subtitle: (mainJson['subtitle'] ?? '').toString(),
      description: (mainJson['description'] ?? '').toString(),
      professionalSummary: (mainJson['professionalSummary'] ?? '').toString(),
      email: (mainJson['email'] ?? '').toString(),
      phone: (mainJson['phone'] ?? '').toString(),
      location: (mainJson['location'] ?? '').toString(),
      cvUrl: (mainJson['cvUrl'] ?? '').toString(),
      techStack: techStackItems.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMainJson() {
    return {
      'name': name,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'professionalSummary': professionalSummary,
      'email': email,
      'phone': phone,
      'location': location,
      'cvUrl': cvUrl,
    };
  }

  Map<String, dynamic> toTechStackJson() {
    return {'items': techStack};
  }
}
