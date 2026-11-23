import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameTrack extends PositionComponent {
  GameTrack({required super.size});

  double scrollOffset = 0;
  double scrollSpeed = 200; // Speed at which the track scrolls

  // Responsive track boundaries.
  double get topLeft => size.x * (size.x < 600 ? 0.38 : 0.43);
  double get topRight => size.x * (size.x < 600 ? 0.62 : 0.57);
  double get bottomLeft => size.x * (size.x < 600 ? 0.08 : 0.20);
  double get bottomRight => size.x * (size.x < 600 ? 0.92 : 0.80);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the path for the game track
    final trackPath = Path();

    trackPath.moveTo(topLeft, size.y * 0.2); // Top-left corner 
    trackPath.lineTo(topRight, size.y * 0.2); // Top-right corner 
    trackPath.lineTo(bottomRight, size.y);       // Bottom-right corner
    trackPath.lineTo(bottomLeft, size.y);       // Bottom-left corner
    trackPath.close();                            // Close the path to form the track shape

    final paint = Paint()
      ..color = const Color(0xFF10152F) // navy blue color for the track
      ..style = PaintingStyle.fill;

    canvas.drawPath(trackPath, paint);  

    final edgeGlowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final leftEdge = Path();

    leftEdge.moveTo(topLeft, size.y * 0.2);
    leftEdge.lineTo(bottomLeft, size.y);
    canvas.drawPath(leftEdge, edgeGlowPaint);

    final edgePaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(leftEdge, edgePaint);

    final rightEdge = Path();
    rightEdge.moveTo(topRight, size.y * 0.2);
    rightEdge.lineTo(bottomRight, size.y);
    canvas.drawPath(rightEdge, edgeGlowPaint);
    canvas.drawPath(rightEdge, edgePaint);

    // Define the dividers for the lanes within the track
    final divider1 = Path();
    final divider2 = Path();

    divider1.moveTo(topLeft + (topRight - topLeft) / 3, size.y * 0.2);
    divider1.lineTo(bottomLeft + (bottomRight - bottomLeft) / 3, size.y);
    divider2.moveTo(topLeft + 2 * (topRight - topLeft) / 3, size.y * 0.2);
    divider2.lineTo(bottomLeft + 2 * (bottomRight - bottomLeft) / 3, size.y); 

    final dividerPaint = Paint()
      ..color = const Color(0xFFFFFFFF) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(divider1, dividerPaint);
    canvas.drawPath(divider2, dividerPaint);

    
    final trackHeight = size.y * 0.8;
    final spacing = trackHeight / 4;

    for (int i = 0; i < 4; i++) {
      final markingY = size.y * 0.2 + (i * spacing + scrollOffset) % trackHeight;
      final trackProgress = (markingY - size.y * 0.2) / trackHeight;
      final leftX = topLeft + (bottomLeft - topLeft) * trackProgress;
      final rightX = topRight + (bottomRight - topRight) * trackProgress;

      final markingPath = Path();
      markingPath.moveTo(leftX, markingY);
      markingPath.lineTo(rightX, markingY);

      if (markingY >= size.y * 0.2 && markingY <= size.y) {
        canvas.drawPath(markingPath, dividerPaint);
      }
    }

  }

  @override
  void update(double dt) {
    super.update(dt);

    scrollOffset = (scrollOffset + scrollSpeed * dt) % (size.y * 0.8);

  }
}