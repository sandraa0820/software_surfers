import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class GameObstacle extends SpriteComponent with CollisionCallbacks {
  double moveSpeed = 200;
  final int laneIndex;
  final int obstacleType;
  final Vector2 screenSize;

  // Tracks whether this obstacle has already been checked for a collision.
  bool hasBeenChecked = false;

  GameObstacle({required super.sprite, required this.laneIndex, required this.obstacleType,
                required this.screenSize, required Vector2 obstacleSize,
                int obstaclePriority = 0})
      : super(
          size: obstacleSize,
          anchor: Anchor.center,
          priority: obstaclePriority,
        );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
  }

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

    // Use responsive track boundaries.
    final isPhone = screenSize.x < 600;

    final topLeft = isPhone ? 0.38 : 0.43;
    final topRight = isPhone ? 0.62 : 0.57;

    final bottomLeft = isPhone ? 0.08 : 0.20;
    final bottomRight = isPhone ? 0.92 : 0.80;

    // Calculate road boundaries at the obstacle's current height.
    final leftX = screenSize.x *
        (topLeft + (bottomLeft - topLeft) * trackProgress);

    final rightX = screenSize.x *
        (topRight + (bottomRight - topRight) * trackProgress);

    // Calculate the width of the entire track.
    final trackWidthAtY = rightX - leftX;

    // Calculate the width of each lane.
    final laneWidthAtY = trackWidthAtY / 3;

    if (obstacleType == 4) {
      // Calculate the bottom of the Laser Barrier.
      final baseY = position.y + (size.y * scale.y / 2);

      // Calculate the track progress at the base.
      final baseProgress =
          (baseY - screenSize.y * 0.2) / (screenSize.y * 0.8);

      // Calculate the track edges at the base of the barrier.
      final baseLeftX = screenSize.x *
          (topLeft + (bottomLeft - topLeft) * baseProgress);

      final baseRightX = screenSize.x *
          (topRight + (bottomRight - topRight) * baseProgress);

      // Calculate the full width at the base.
      final baseTrackWidth = baseRightX - baseLeftX;

      // Center the Laser Barrier.
      position.x = (baseLeftX + baseRightX) / 2;

      // Align the support pillars with the track edges.
      scale.x = (baseTrackWidth * 1.15) / size.x;
    } else {
      // Keep regular obstacles centered in their assigned lane.
      position.x =
          leftX + laneWidthAtY * (laneIndex + 0.5);
    }
    
    // Remove the obstacle if it goes off the bottom of the screen.
    if (position.y > screenSize.y + size.y / 2) {
      removeFromParent();
    }
  }
}