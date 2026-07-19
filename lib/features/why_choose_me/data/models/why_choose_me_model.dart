import 'package:flutter/material.dart';
import '../../domain/entities/why_choose_me_entity.dart';

class WhyChooseMeModel extends WhyChooseMeItem {
  const WhyChooseMeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.color,
    required super.icon,
  });

  factory WhyChooseMeModel.fromJson(Map<String, dynamic> json, String id) {
    final title = (json['title'] ?? json['name'] ?? json['heading'] ?? '').toString();
    final description = (json['description'] ?? json['details'] ?? json['text'] ?? '').toString();

    Color itemColor = const Color(0xFF00D9FF);
    final rawColor = json['color'];
    if (rawColor != null) {
      try {
        if (rawColor is num) {
          itemColor = Color(rawColor.toInt());
        } else if (rawColor is String) {
          final hex = rawColor.replaceAll('#', '');
          itemColor = Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
        }
      } catch (_) {}
    }

    int icon = Icons.star_rounded.codePoint;
    final rawIcon = json['icon'];
    if (rawIcon != null) {
      if (rawIcon is num) {
        icon = rawIcon.toInt();
      } else {
        icon = int.tryParse(rawIcon.toString()) ?? icon;
      }
    }

    return WhyChooseMeModel(
      id: id,
      title: title,
      description: description,
      color: itemColor,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'color': color.value,
      'icon': icon,
    };
  }
}
