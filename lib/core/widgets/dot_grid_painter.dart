import 'package:flutter/material.dart';

/// A faint repeating dot grid, useful as a subtle texture over a flat
/// gradient/color block so it reads as a designed surface rather than an
/// empty block of color.
class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double dotRadius;

  const DotGridPainter({
    required this.color,
    this.spacing = 28,
    this.dotRadius = 1.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return color != oldDelegate.color ||
        spacing != oldDelegate.spacing ||
        dotRadius != oldDelegate.dotRadius;
  }
}
