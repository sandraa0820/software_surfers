import 'package:flame/components.dart';

class GameObstacle extends SpriteComponent {
  double moveSpeed = 200;
  final int laneIndex;
  final Vector2 screenSize;

  GameObstacle({required super.sprite, required this.laneIndex, required this.screenSize})
      : super(
          size: Vector2.all(50.0),
          anchor: Anchor.center,
          priority: 0,
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Move the obstacle downward.
    position.y += moveSpeed * dt;

    // Calculate its progress along the track.
    final trackProgress =
        (position.y - screenSize.y * 0.2) / (screenSize.y * 0.8);
    
    final scaleFactor = 0.6 + (0.6 * trackProgress.clamp(0.0, 1.0));

    scale = Vector2.all(scaleFactor);

    // Calculate road boundaries at its current height.
    final leftX =
        screenSize.x * (0.43 - 0.23 * trackProgress);

    final rightX =
        screenSize.x * (0.57 + 0.23 * trackProgress);

    // Calculate the width of each lane.
    final laneWidthAtY = (rightX - leftX) / 3;

    // Keep the obstacle centered in its assigned lane.
    position.x =
        leftX + laneWidthAtY * (laneIndex + 0.5);
    
    // Remove the obstacle if it goes off the bottom of the screen.
    if (position.y > screenSize.y + size.y / 2) {
      removeFromParent();
    }
  }
}