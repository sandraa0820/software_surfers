import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'dart:math';


import 'world/game_track.dart';
import 'world/computer_background.dart';
import 'player/surfer_player.dart';
import 'obstacles/game_obstacle.dart';

class SoftwareSurfersGame extends FlameGame with HasKeyboardHandlerComponents {
  late SurferPlayer surferPlayer;
  late Sprite bugSprite;
  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFF10152F);

  double spawnTimer = 0.0;
  double spawnInterval = 2.0; // Time interval between obstacle spawns in seconds

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final background = SpriteComponent(
      sprite: await loadSprite('CS_background.png'),
      size: size,
      priority: -2,
    );

    add(background);

    // Add the game track to the game
    add(GameTrack(size: size)..priority = -1);
    //add(ComputerBackground(size: size)..priority = -2);

    // Track width at the player's height
    final trackWidth = size.x * 0.480; // Width of the track

    // Divide the track into three lanes
    final laneWidth = trackWidth / 3;

    final surferPlayer = SurferPlayer(laneWidth: laneWidth);

    surferPlayer.position = Vector2(
      size.x / 2,
      size.y * 0.75,
    );

    await add(surferPlayer);
    bugSprite = await loadSprite('obstacles/bug.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0.0;
      spawnObstacle();
    }
  }
 
  void spawnObstacle() {
    final laneIndex = random.nextInt(3); // Randomly choose a lane (0, 1, or 2)
    final bug = GameObstacle(sprite: bugSprite, laneIndex: laneIndex, screenSize: size.clone());
    // Position the bug at the start of the track.
    final obstacleY = size.y * 0.20;

    // Calculate how far down the track the bug is.
    final trackProgress =
        (obstacleY - size.y * 0.2) / (size.y * 0.8);

    // Calculate the road boundaries at the bug's height.
    final leftX = size.x * (0.43 - 0.23 * trackProgress);
    final rightX = size.x * (0.57 + 0.23 * trackProgress);

    // Divide the road into three lanes.
    final trackWidthAtY = rightX - leftX;
    final laneWidthAtY = trackWidthAtY / 3;

    // Calculate the center of the right lane (index 2).
    final laneCenterX = leftX + laneWidthAtY * (laneIndex + 0.5);

    bug.position = Vector2(laneCenterX, obstacleY);
    add(bug);
  }
}