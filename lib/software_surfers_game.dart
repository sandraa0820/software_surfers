import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'world/game_track.dart';
import 'player/surfer_player.dart';
import 'obstacles/game_obstacle.dart';
import 'collectibles/game_collectible.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SoftwareSurfersGame extends FlameGame with HasKeyboardHandlerComponents,
                                  HasCollisionDetection {
                        
  final List<SpawnReservation> spawnReservations = [];

  static const double objectMoveSpeed = 200.0;
  static const double extraSpacing = 25.0;

  late SurferPlayer surferPlayer;
  late List<Sprite> obstacleSprites;
  late Sprite collectibleSprite;
  late Sprite bonusChipSprite;

  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFF10152F);

  double spawnTimer = 0.0;
  double spawnInterval = 2.0; // Time interval between obstacle spawns in seconds
  int health = 2; // Player starts with two hearts.
  double distance = 0.0;
  double runningSpeed = 10.0;
  double collectibleTimer = 0.0;
  double collectibleInterval = 3.0;
  double gameTime = 0.0; // Elapsed gameplay time.

  // Tracks when each lane was last used.
  final List<double> laneSafeUntil = [0.0, 0.0, 0.0];

  // Bonus Chip spawning.
  double bonusChipTimer = 0.0;
  double bonusChipInterval = 12.0;

  // Data Byte scoring.
  int dataBytesCollected = 0;
  int score = 0;
  // High score persistence.
  int highScore = 0;

  // Notifies the HUD when the score changes.
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> distanceNotifier = ValueNotifier<int>(0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadHighScore();

    collectibleSprite = await loadSprite('collectibles/data_byte.png');
    bonusChipSprite = await loadSprite('collectibles/bonus_chip.png');

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

   surferPlayer = SurferPlayer(laneWidth: laneWidth);

    surferPlayer.position = Vector2(
      size.x / 2,
      size.y * 0.75,
    );

    await add(surferPlayer);

    obstacleSprites = [
      await loadSprite('obstacles/bug.png'),
      await loadSprite('obstacles/virus.png'),
      await loadSprite('obstacles/error.png'),
      await loadSprite('obstacles/server_block.png'),
      await loadSprite('obstacles/barrier.png')
      
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTime += dt;

    // Increase the distance as the player runs.
    distance += runningSpeed * dt;
    distanceNotifier.value = distance.toInt();

    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer -= spawnInterval;
      spawnObstacle();
    }

    // Spawn Data Bytes.
    collectibleTimer += dt;
    if (collectibleTimer >= collectibleInterval) {
      collectibleTimer -= collectibleInterval;
      spawnDataByte();
    }

    // Spawn Bonus ChipS EVERY 12 seconds.
    bonusChipTimer += dt;
    if (bonusChipTimer >= bonusChipInterval) {
      bonusChipTimer -= bonusChipInterval;
      spawnBonusChip();
    }

    // Check for obstacle and collectible collisions.
    checkObstacleCollisions();
    checkCollectibleCollisions();

    spawnReservations.removeWhere((reservation) {
      final currentY = reservation.startY +
          objectMoveSpeed * (gameTime - reservation.spawnTime);

      return currentY > size.y + 200;
    });
  }

  // Helper for spawn safety checks.
  bool positionsOverlap(
  double firstY,
  double secondY,
  double safeDistance,)
  {
    return (firstY - secondY).abs() < safeDistance;
  }

  bool canSpawnAt({
    required int lane,
    required double y,
    required double halfHeight,
    bool isLaser = false,
  }) {
    for (final reservation in spawnReservations) {
      if (reservation.lane != lane) continue;

      // Laser barriers are allowed to share a lane with Data Bytes.
      if (isLaser || reservation.isLaser) continue;

      // Calculate where the existing object should be now.
      final existingY = reservation.startY +
          objectMoveSpeed * (gameTime - reservation.spawnTime);

      // Allow enough room for both objects.
      final minimumGap =
          halfHeight + reservation.halfHeight + extraSpacing;

      if ((y - existingY).abs() < minimumGap) {
        return false;
      }
    }

    return true;
  }
  
  void spawnObstacle() {
    // Randomly choose an obstacle.
    final obstaclesIndex = random.nextInt(obstacleSprites.length);
    final selectedSprite = obstacleSprites[obstaclesIndex];

    // Assign a size based on the selected obstacle.
    final obstacleSizes = [
      Vector2(68, 72),    // Bug - Jump
      Vector2(65, 70),    // Virus - Jump
      Vector2(90, 70),    // Error - Jump
      Vector2(115, 164),  // Server block - Change lanes
      Vector2(170, 175),  // Laser barrier - Slide
    ];

    final selectedSize = obstacleSizes[obstaclesIndex];

    // Starting position of the obstacle.
    final obstacleY = size.y * 0.20;

    // Find lanes that are safe for spawning.
    final availableLanes = <int>[];

    for (int lane = 0; lane < 3; lane++) {
      if (canSpawnAt(
        lane: lane,
        y: obstacleY,
        halfHeight: selectedSize.y * 0.6,
        isLaser: obstaclesIndex == 4,
      )) {
        availableLanes.add(lane);
      }
    }

    // Skip spawning if all lanes are occupied.
    if (availableLanes.isEmpty) {
      return;
    }

    // Choose a safe lane BEFORE creating the obstacle.
    final laneIndex =
        availableLanes[random.nextInt(availableLanes.length)];

    // Create the obstacle.
    final obstacle = GameObstacle(
      sprite: selectedSprite,
      laneIndex: laneIndex,
      screenSize: size.clone(),
      obstacleSize: selectedSize,
      obstacleType: obstaclesIndex,
      obstaclePriority: obstaclesIndex == 4 ? 2 : 0,
    );

    // Calculate perspective.
    final trackProgress =
        (obstacleY - size.y * 0.2) / (size.y * 0.8);

    // Calculate the road boundaries.
    final leftX =
        size.x * (0.43 - 0.23 * trackProgress);

    final rightX =
        size.x * (0.57 + 0.23 * trackProgress);

    // Divide the track into three lanes.
    final laneWidthAtY = (rightX - leftX) / 3;

    // Calculate the center of the selected lane.
    final laneCenterX =
        leftX + laneWidthAtY * (laneIndex + 0.5);

    // Position the obstacle.
    obstacle.position = Vector2(laneCenterX, obstacleY);

    // Register the obstacle immediately.
    spawnReservations.add(
      SpawnReservation(
        lane: laneIndex,
        startY: obstacleY,
        halfHeight: selectedSize.y * 0.6,
        spawnTime: gameTime,
        isLaser: obstaclesIndex == 4,
      ),
    );

    // Add the obstacle to the game.
    add(obstacle);
  }


  void checkObstacleCollisions() {
    final obstacles = children.whereType<GameObstacle>().toList();

    for (final obstacle in obstacles) {
      // Skip obstacles we've already checked.
      if (obstacle.hasBeenChecked) {
        continue;
      }

      // Wait until the obstacle reaches the player's position.
      if (obstacle.position.y >= surferPlayer.groundY) {
        obstacle.hasBeenChecked = true;

        // The player is safe if they are in a different lane.
        if (obstacle.laneIndex != surferPlayer.currentLane) {
          continue;
        }

        // Check the action required for each obstacle type.
        switch (obstacle.obstacleType) {
          case 0: // Bug - Jump
          case 1: // Virus - Jump
          case 2: // Error - Jump
            if (!surferPlayer.isJumping) {
              takeDamage();
            }
            break;

            case 3: // Server block - Change lanes
            // The player must switch lanes to avoid the server block.
            takeDamage();
            break;

            case 4: // Laser barrier - Slide
            if (!surferPlayer.isSliding) {
              takeDamage();
            }
            break;
        }
      }
    }
  }

  void takeDamage() {
    if (health <= 0) {
      return;
    }

    health--;

    // Refresh the HUD to display the updated health.
    overlays.remove('Hud');
    overlays.add('Hud');

    if (health == 0) {
      pauseEngine();

      // Update the high score when the game ends.
      updateHighScore();

      // Show the Game Over overlay.
      overlays.add('GameOver');
    }
  }

  void spawnDataByte() {
    // Check the full four-Data-Byte trail.
    final availableLanes = <int>[];

    for (int lane = 0; lane < 3; lane++) {
      bool safe = true;

      for (int i = 0; i < 4; i++) {
        final collectibleY = size.y * 0.17 + (i * 58.0);

        if (!canSpawnAt(
          lane: lane,
          y: collectibleY,
          halfHeight: 40.0,
        )) {
          safe = false;
          break;
        }
      }

      if (safe) availableLanes.add(lane);
    }

    if (availableLanes.isEmpty) return;

    final laneIndex =
        availableLanes[random.nextInt(availableLanes.length)];

      // Reserve this lane while the Data Byte trail passes.
      laneSafeUntil[laneIndex] = gameTime + 2.0;

      // Create a trail of five Data Bytes.
      for (int i = 0; i < 4; i++) {
        final dataByte = GameCollectible(
          sprite: collectibleSprite,
          laneIndex: laneIndex,
          screenSize: size.clone(),
        );

      // Space the Data Bytes along the track.
      final collectibleY = size.y * 0.17 + (i * 58.0);

      // Calculate perspective.
      final trackProgress =
          (collectibleY - size.y * 0.2) / (size.y * 0.8);

      final leftX =
          size.x * (0.43 - 0.23 * trackProgress);

      final rightX =
          size.x * (0.57 + 0.23 * trackProgress);

      final laneWidthAtY = (rightX - leftX) / 3;

      final laneCenterX =
          leftX + laneWidthAtY * (laneIndex + 0.5);

      dataByte.position = Vector2(laneCenterX, collectibleY);

    spawnReservations.add(
      SpawnReservation(
        lane: laneIndex,
        startY: collectibleY,
        halfHeight: 40.0,
        spawnTime: gameTime,
      ),
    );

      add(dataByte);
    }
  }

  void spawnBonusChip() {
    final bonusChipY = size.y * 0.17;
    const bonusChipHalfHeight = 40.0;

    // Find lanes without overlapping objects.
    final availableLanes = <int>[];

    for (int lane = 0; lane < 3; lane++) {
      if (canSpawnAt(
        lane: lane,
        y: bonusChipY,
        halfHeight: bonusChipHalfHeight,
      )) {
        availableLanes.add(lane);
      }
    }

    // Skip spawning if all lanes are occupied.
    if (availableLanes.isEmpty) return;

    final laneIndex =
        availableLanes[random.nextInt(availableLanes.length)];

    // Create the Bonus Chip using our existing collectible class.
    final bonusChip = GameCollectible(
      sprite: bonusChipSprite,
      laneIndex: laneIndex,
      screenSize: size.clone(),
      isBonusChip: true,
    );

    // Make the Bonus Chip slightly bigger.
    bonusChip.size = Vector2(80, 80);

    // Calculate its position on the perspective track.
    final trackProgress =
        (bonusChipY - size.y * 0.2) / (size.y * 0.8);

    final leftX = size.x * (0.43 - 0.23 * trackProgress);
    final rightX = size.x * (0.57 + 0.23 * trackProgress);
    final laneWidthAtY = (rightX - leftX) / 3;

    final laneCenterX =
        leftX + laneWidthAtY * (laneIndex + 0.5);

    bonusChip.position = Vector2(laneCenterX, bonusChipY);

    // Reserve its position to prevent unwanted overlaps.
    spawnReservations.add(
      SpawnReservation(
        lane: laneIndex,
        startY: bonusChipY,
        halfHeight: bonusChipHalfHeight,
        spawnTime: gameTime,
      ),
    );

    add(bonusChip);
  }

  void checkCollectibleCollisions() {
    final collectibles = children.whereType<GameCollectible>().toList();

    for (final collectible in collectibles) {
      // Don't check the same Data Byte twice.
      if (collectible.hasBeenCollected) {
        continue;
      }

      // Wait until it reaches the player's position.
      if (collectible.position.y >= surferPlayer.groundY) {
        collectible.hasBeenCollected = true;

        // Check if the player is in the same lane as the collectible.
        if (collectible.laneIndex == surferPlayer.currentLane) {
          if (collectible.isBonusChip) {
            // Bonus Chips are worth 20 points.
            score += 20;
          } else {
            // Regular Data Bytes are worth 1 point.
            dataBytesCollected++;
            score++;
          }

          // Update the score display.
          scoreNotifier.value = score;

          // Remove the collected collectible.
          collectible.removeFromParent();
        }
      }
    }
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();

    highScore = prefs.getInt('highScore') ?? 0;
  }

  Future<void> updateHighScore() async {
    if (score > highScore) {
      highScore = score;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
    }
  }

}

class SpawnReservation {
  final int lane;
  final double startY;
  final double halfHeight;
  final double spawnTime;
  final bool isLaser;

  SpawnReservation({
    required this.lane,
    required this.startY,
    required this.halfHeight,
    required this.spawnTime,
    this.isLaser = false,
  });
}