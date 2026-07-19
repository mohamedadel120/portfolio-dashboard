import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Expertise extends Equatable {
  final String id;
  final String title;
  final String category;
  final int percentage;
  final Color color;
  final String? icon;

  const Expertise({
    required this.id,
    required this.title,
    required this.category,
    required this.percentage,
    required this.color,
    this.icon,
  });

  @override
  List<Object?> get props => [id, title, category, percentage, color, icon];
}
