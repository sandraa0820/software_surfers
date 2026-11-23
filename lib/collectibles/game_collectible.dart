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

    // Use the same responsive boundaries as GameTrack.
    final isPhone = screenSize.x < 600;

    final topLeft = isPhone ? 0.38 : 0.43;
    final topRight = isPhone ? 0.62 : 0.57;

    final bottomLeft = isPhone ? 0.08 : 0.20;
    final bottomRight = isPhone ? 0.92 : 0.80;

    // Calculate the track boundaries at the collectible's position.
    final leftX = screenSize.x *
        (topLeft + (bottomLeft - topLeft) * trackProgress);

    final rightX = screenSize.x *
        (topRight + (bottomRight - topRight) * trackProgress);

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