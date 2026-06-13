// lib/widgets/painters/islamic_pattern_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class IslamicPatternPainter extends CustomPainter {
  final Color color;

  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double spacing = 60.0;
    
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 25, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double r = (i % 2 == 0) ? radius : radius * 0.7;
      double px = center.dx + r * math.cos(angle);
      double py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw the squares
    double side = radius * 1.4;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: side, height: side), paint);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: side, height: side), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
