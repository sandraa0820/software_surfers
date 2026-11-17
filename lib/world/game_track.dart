import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameTrack extends PositionComponent {
  GameTrack({required super.size});

  double scrollOffset = 0;
  double scrollSpeed = 200; // Speed at which the track scrolls

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define the path for the game track
    final trackPath = Path();

    trackPath.moveTo(size.x * 0.43, size.y * 0.2); // Top-left corner 
    trackPath.lineTo(size.x * 0.57, size.y * 0.2); // Top-right corner 
    trackPath.lineTo(size.x * 0.8, size.y);       // Bottom-right corner
    trackPath.lineTo(size.x * 0.2, size.y);       // Bottom-left corner
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

    leftEdge.moveTo(size.x * 0.43, size.y * 0.2);
    leftEdge.lineTo(size.x * 0.2, size.y);
    canvas.drawPath(leftEdge, edgeGlowPaint);

    final edgePaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(leftEdge, edgePaint);

    final rightEdge = Path();
    rightEdge.moveTo(size.x * 0.57, size.y * 0.2);
    rightEdge.lineTo(size.x * 0.8, size.y);
    canvas.drawPath(rightEdge, edgeGlowPaint);
    canvas.drawPath(rightEdge, edgePaint);

    // Define the dividers for the lanes within the track
    final divider1 = Path();
    final divider2 = Path();

    divider1.moveTo(size.x * (0.43 + 0.14 / 3), size.y * 0.2);
    divider1.lineTo(size.x * 0.43, size.y);
    divider2.moveTo(size.x * (0.43 + 0.14 * 2 / 3), size.y * 0.2);
    divider2.lineTo(size.x * 0.57, size.y); 

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
      final leftX = size.x * (0.43 - 0.23 * trackProgress);
      final rightX = size.x * (0.57 + 0.23 * trackProgress);

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