import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';


class SurferPlayer extends SpriteAnimationComponent with KeyboardHandler, 
                          CollisionCallbacks {
  // Animations for running, jumping, and sliding
  late SpriteAnimation runAnimation;
  late SpriteAnimation jumpAnimation;
  late SpriteAnimation slideAnimation;

  // The current lane of the surfer player (0 = left, 1 = center, 2 = right)
  int currentLane = 1;

  // The width of each lane = 200
  final double laneWidth;

  // variables for jumping and gravity
  bool isJumping = false;
  bool isSliding = false;
  double gravity = 1000;
  double groundY = 0;
  double verticalVelocity = 0;
  double slideDuration = 0.8; // Duration of the slide action
  double slideTimer = 0; // Timer to track the slide action duration
  final double jumpSpeed = 500;

  SurferPlayer({required this.laneWidth})
      : super(
          size: Vector2(100, 140),
          anchor: Anchor.center,
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: Vector2(50, 70),
      position: Vector2(25, 60), // Center the hitbox within the component
    ));

    groundY = position.y;

    final runFrames = await Future.wait([
      Sprite.load('software_surfers_player/running/run_1.png'),
      Sprite.load('software_surfers_player/running/run_2.png'),
      Sprite.load('software_surfers_player/running/run_3.png'),
      Sprite.load('software_surfers_player/running/run_4.png'),
    ]);

     runAnimation = SpriteAnimation.spriteList(
      runFrames, 
      stepTime: 0.15,
      loop: true,
    );

    animation = runAnimation;

    final jumpFrames = await Future.wait([
      Sprite.load('software_surfers_player/jumping/jump_1.png'),
      Sprite.load('software_surfers_player/jumping/jump_2.png'),
      Sprite.load('software_surfers_player/jumping/jump_3.png'),
    ]);

    jumpAnimation = SpriteAnimation.spriteList(
      jumpFrames,
      stepTime: 0.15,
      loop: false,
    );

    final slideFrames = await Future.wait([
      Sprite.load('software_surfers_player/sliding/slide_1.png'),
      Sprite.load('software_surfers_player/sliding/slide_2.png'),
      Sprite.load('software_surfers_player/sliding/slide_3.png'),
    ]);

    slideAnimation = SpriteAnimation.spriteList(
      slideFrames,
      stepTime: 0.20,
      loop: false,
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
        // Move up (jump)
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (!isJumping && !isSliding) {
          isJumping = true;
          verticalVelocity = -jumpSpeed;
          animation = jumpAnimation;
        }
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        if(!isSliding && !isJumping) {
          isSliding = true;
          animation = slideAnimation;
        }
      }
    }
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isJumping) {
      verticalVelocity += gravity * dt;
      position.y += verticalVelocity * dt;

      // Check if the player has landed
      if (position.y >= groundY) { // Assuming ground level at 75% of screen height
        position.y = groundY;
        isJumping = false;
        verticalVelocity = 0.0;
        animation = runAnimation;
      }
    }

    if (isSliding) {
      slideTimer += dt;

      if (slideTimer >= slideDuration) {
        isSliding = false;
        slideTimer = 0;
        animation = runAnimation;
      }
    }
  }
  
}