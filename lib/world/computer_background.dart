import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ComputerBackground extends PositionComponent {
  ComputerBackground({required super.size});

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final circuitPaint = Paint()
      ..color = const Color(0xFF00FFFF) // glowing color for the circuit
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final circuitPath = Path();
    circuitPath.moveTo(size.x * 0.1, size.y * 0.3);
    circuitPath.lineTo(size.x * 0.15, size.y * 0.3);
    circuitPath.lineTo(size.x * 0.15, size.y * 0.4);

    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(circuitPath, glowPaint);
    canvas.drawPath(circuitPath, circuitPaint);
  }
}