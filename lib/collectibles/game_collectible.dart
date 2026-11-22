import 'package:flame/components.dart';

class GameCollectible extends SpriteComponent {
  final int laneIndex;
  final Vector2 screenSize;
  final bool isBonusChip;

  double moveSpeed = 200;
  bool hasBeenCollected = false;

  GameCollectible({
    required super.sprite,
    required this.laneIndex,
    required this.screenSize,
    this.isBonusChip = false,
  }) : super(
          size: Vector2(65, 65),
          anchor: Anchor.center,
          priority: 0,
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Move toward the player.
    position.y += moveSpeed * dt;

    // Calculate perspective.
    final trackProgress =
        (position.y - screenSize.y * 0.2) /
        (screenSize.y * 0.8);

    final scaleFactor =
        0.6 + (0.6 * trackProgress.clamp(0.0, 1.0));

    scale = Vector2.all(scaleFactor);

    // Calculate the track boundaries.
    final leftX =
        screenSize.x * (0.43 - 0.23 * trackProgress);

    final rightX =
        screenSize.x * (0.57 + 0.23 * trackProgress);

    // Keep the collectible in its assigned lane.
    final laneWidthAtY = (rightX - leftX) / 3;

    position.x =
        leftX + laneWidthAtY * (laneIndex + 0.5);

    // Remove the collectible after it leaves the screen.
    if (position.y > screenSize.y + size.y / 2) {
      removeFromParent();
    }
  }
}