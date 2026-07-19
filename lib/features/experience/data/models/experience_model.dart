import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/experience_entity.dart';

class ExperienceModel extends Experience {
  const ExperienceModel({
    required super.id,
    required super.company,
    required super.role,
    required super.startDate,
    required super.endDate,
    required super.description,
    required super.location,
    super.logoUrl,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json, String id) {
    final company = (json['company'] ?? json['companyName'] ?? json['org'] ?? '').toString();
    final role = (json['role'] ?? json['title'] ?? json['position'] ?? '').toString();

    String parseDate(dynamic dateVal) {
      if (dateVal == null) return '';
      if (dateVal is String) return dateVal;
      try {
        if (dateVal is Timestamp) {
          final date = dateVal.toDate();
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return "${months[date.month - 1]} ${date.year}";
        }
      } catch (_) {}
      return dateVal.toString();
    }

    String startDate = parseDate(json['startDate'] ?? json['start'] ?? json['from']);
    String endDate = parseDate(json['endDate'] ?? json['end'] ?? json['to']);

    if (startDate.isEmpty && endDate.isEmpty) {
      final period = json['period']?.toString() ?? '';
      if (period.isNotEmpty) {
        final parts = period.split(RegExp(r'\s*[–—-]\s*'));
        if (parts.length == 2) {
          startDate = parts[0].trim();
          endDate = parts[1].trim();
        } else {
          startDate = period.trim();
        }
      }
    }
    if (endDate.isEmpty) endDate = 'Present';

    String description = '';
    final rawDesc = json['description'] ??
        json['details'] ??
        json['points'] ??
        json['bullets'] ??
        json['achievements'];
    if (rawDesc != null) {
      if (rawDesc is List) {
        description = rawDesc.map((e) => e.toString()).join('\n');
      } else {
        description = rawDesc.toString();
      }
    }

    final location = (json['location'] ?? json['address'] ?? json['city'] ?? '').toString();
    final logoUrl = json['logoUrl']?.toString() ?? json['logo']?.toString() ?? json['image']?.toString();

    return ExperienceModel(
      id: id,
      company: company,
      role: role,
      startDate: startDate,
      endDate: endDate,
      description: description,
      location: location,
      logoUrl: logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    final bullets = description.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return {
      'company': company,
      'companyName': company, // compatibility fallback
      'role': role,
      'title': role, // compatibility fallback
      'startDate': startDate,
      'endDate': endDate,
      'period': '$startDate – $endDate', // compatibility fallback
      // Save description as List of bullet points if it contains newlines,
      // or as a single string for compatibility
      'description': bullets.length > 1 ? bullets : description,
      'achievements': bullets, // compatibility fallback
      'location': location,
      'logoUrl': logoUrl,
    };
  }
}
