import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class WhyChooseMeItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final Color color;
  final int icon;

  const WhyChooseMeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, description, color, icon];
}
