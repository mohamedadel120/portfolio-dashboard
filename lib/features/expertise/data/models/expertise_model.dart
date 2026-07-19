import 'package:flutter/material.dart';
import '../../domain/entities/expertise_entity.dart';

class ExpertiseModel extends Expertise {
  const ExpertiseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.percentage,
    required super.color,
    super.icon,
  });

  factory ExpertiseModel.fromJson(Map<String, dynamic> json, String id) {
    // Highly resilient parsing using .toString() and tryParse to prevent any TypeErrors
    final title = (json['title'] ?? json['name'] ?? '').toString();
    final category = (json['category'] ?? '').toString();
    
    int percentage = 0;
    final rawPercentage = json['percentage'] ?? json['level'] ?? json['proficiency'];
    if (rawPercentage != null) {
      if (rawPercentage is num) {
        percentage = rawPercentage.toInt();
      } else {
        percentage = int.tryParse(rawPercentage.toString()) ?? 0;
      }
    }
    
    Color skillColor = const Color(0xFF00D9FF);
    if (json['color'] != null) {
      try {
        final rawColor = json['color'];
        if (rawColor is num) {
          skillColor = Color(rawColor.toInt());
        } else if (rawColor is String) {
          final hex = rawColor.replaceAll('#', '');
          skillColor = Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
        }
      } catch (_) {}
    }

    final icon = json['icon']?.toString();

    return ExpertiseModel(
      id: id,
      title: title,
      category: category,
      percentage: percentage,
      color: skillColor,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'name': title, // compatibility fallback
      'category': category,
      'percentage': percentage,
      'level': percentage, // compatibility fallback
      'color': color.value,
      'icon': icon,
    };
  }
}
