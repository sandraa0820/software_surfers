import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class SurferPlayer extends SpriteAnimationComponent with KeyboardHandler {
  // The current lane of the surfer player (0 = left, 1 = center, 2 = right)
  int currentLane = 1;

  // The width of each lane = 200
  final double laneWidth;

  SurferPlayer({required this.laneWidth})
      : super(
          size: Vector2(100, 140),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final runFrames = await Future.wait([
      Sprite.load('software_surfers_player/running/run_1.png'),
      Sprite.load('software_surfers_player/running/run_2.png'),
      Sprite.load('software_surfers_player/running/run_3.png'),
      Sprite.load('software_surfers_player/running/run_4.png'),
    ]);

    animation = SpriteAnimation.spriteList(
      runFrames, 
      stepTime: 0.15,
      loop: true,
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Move right
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        if (currentLane < 2) {
          currentLane++;
          position.x += laneWidth;
        }

        // Move left
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        if (currentLane > 0) {
          currentLane--;
          position.x -= laneWidth;
        }
      }
    }
    return true;
  }
}