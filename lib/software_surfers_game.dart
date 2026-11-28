import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'main.dart';
import 'dart:math';

import 'world/game_track.dart';
import 'player/surfer_player.dart';
import 'obstacles/game_obstacle.dart';
import 'collectibles/game_collectible.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SoftwareSurfersGame extends FlameGame with HasKeyboardHandlerComponents,
                                  HasCollisionDetection, PanDetector {
                        
  final List<SpawnReservation> spawnReservations = [];

  Vector2 swipeDistance = Vector2.zero();
  bool swipeHandled = false;

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
  void onPanStart(DragStartInfo info) {
    swipeDistance = Vector2.zero();
    swipeHandled = false;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (swipeHandled || health <= 0) return;

    swipeDistance += info.delta.global;

    // Minimum distance required to detect a swipe.
    if (swipeDistance.length < 15) return;

    if (swipeDistance.x.abs() > swipeDistance.y.abs()) {
      if (swipeDistance.x > 0) {
        surferPlayer.moveRight();
        debugPrint('Swipe RIGHT detected');
      } else {
        surferPlayer.moveLeft();
        debugPrint('Swipe LEFT detected');
      }
    } else {
      if (swipeDistance.y < 0) {
        surferPlayer.jump();
        debugPrint('Swipe UP detected');
      } else {
        surferPlayer.slide();
        debugPrint('Swipe DOWN detected');
      }
    }

    // Prevent multiple actions from a single swipe.
    swipeHandled = true;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    swipeDistance = Vector2.zero();
    swipeHandled = false;
  }

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

    // Calculate the track width at the player's position.
    final isPhone = size.x < 600;

    // Track boundaries at the player's height (75% of screen).
    final trackProgress = (0.75 - 0.20) / 0.80;

    final topLeft = isPhone ? 0.38 : 0.43;
    final topRight = isPhone ? 0.62 : 0.57;

    final bottomLeft = isPhone ? 0.08 : 0.20;
    final bottomRight = isPhone ? 0.92 : 0.80;

    // Calculate the left and right edges.
    final leftX = size.x *
        (topLeft + (bottomLeft - topLeft) * trackProgress);

    final rightX = size.x *
        (topRight + (bottomRight - topRight) * trackProgress);

    // Divide the track into three equal lanes.
    final laneWidth = (rightX - leftX) / 3;

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

    pauseEngine();
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
    bool isCollectible = false,
  }) {
    for (final reservation in spawnReservations) {
      if (reservation.lane != lane) continue;

      // Allow Laser Barriers to overlap only with collectibles.
      if ((isLaser && reservation.isCollectible) ||
          (isCollectible && reservation.isLaser)) {
        continue;
      }

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
      Vector2(67, 72),    // Bug - Jump
      Vector2(65, 70),    // Virus - Jump
      Vector2(66, 70),    // Error - Jump
      Vector2(66, 165),  // Server block - Change lanes
      Vector2(125, 173),  // Laser barrier - Slide
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

    // Check if the selected obstacle is a Laser Barrier.
    final isLaser = obstaclesIndex == 4;

    // Skip spawning if no lanes are available.
    if (availableLanes.isEmpty) {
      return;
    }

    // Laser Barriers require all three lanes to be available.
    if (isLaser && availableLanes.length != 3) {
      return;
    }

    // Center the Laser Barrier in the middle lane.
    // Other obstacles continue to use a random available lane.
    final laneIndex = isLaser
        ? 1
        : availableLanes[random.nextInt(availableLanes.length)];

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

    // Use the same track boundaries as GameTrack.
    final isPhone = size.x < 600;

    final topLeft = isPhone ? 0.38 : 0.43;
    final topRight = isPhone ? 0.62 : 0.57;

    final bottomLeft = isPhone ? 0.08 : 0.20;
    final bottomRight = isPhone ? 0.92 : 0.80;

    // Calculate the road boundaries at this obstacle's position.
    final leftX = size.x *
        (topLeft + (bottomLeft - topLeft) * trackProgress);

    final rightX = size.x *
        (topRight + (bottomRight - topRight) * trackProgress);

    // Divide the track into three lanes.
    final laneWidthAtY = (rightX - leftX) / 3;

    // Calculate the center of the selected lane.
    final laneCenterX =
        leftX + laneWidthAtY * (laneIndex + 0.5);

    // Position the obstacle.
    obstacle.position = Vector2(laneCenterX, obstacleY);

    /// Determine which lanes need to be reserved.
    final reservedLanes = isLaser
        ? [0, 1, 2]
        : [laneIndex];

    // Register the obstacle in the required lanes.
    for (final lane in reservedLanes) {
      spawnReservations.add(
        SpawnReservation(
          lane: lane,
          startY: obstacleY,
          halfHeight: selectedSize.y * 0.6,
          spawnTime: gameTime,
          isLaser: isLaser,
        ),
      );
    }

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

        // Regular obstacles can be avoided by switching lanes.
        // Laser Barriers cover all three lanes.
        if (obstacle.obstacleType != 4 &&
            obstacle.laneIndex != surferPlayer.currentLane) {
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

    // Flash the player to indicate damage.
    if (health > 0) {
      surferPlayer.flashDamage();
    }

    // Refresh the HUD to display the updated health.
    overlays.remove('Hud');
    overlays.add('Hud');

    if (health == 0) {
      pauseEngine();
      MusicManager.instance.play(MusicTrack.gameOver);
      // Update the high score when the game ends.
      updateHighScore();

      // Show the Game Over overlay.
      overlays.add('GameOver');
    }
  }

  // Calculate the center of a lane at a specific height.
  double laneCenterAtY(int laneIndex, double y) {
    final isPhone = size.x < 600;

    final topLeft = isPhone ? 0.38 : 0.43;
    final topRight = isPhone ? 0.62 : 0.57;
    final bottomLeft = isPhone ? 0.08 : 0.20;
    final bottomRight = isPhone ? 0.92 : 0.80;

    final trackProgress =
        (y - size.y * 0.2) / (size.y * 0.8);

    final leftX = size.x *
        (topLeft + (bottomLeft - topLeft) * trackProgress);

    final rightX = size.x *
        (topRight + (bottomRight - topRight) * trackProgress);

    final laneWidthAtY = (rightX - leftX) / 3;

    return leftX + laneWidthAtY * (laneIndex + 0.5);
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
          isCollectible: true,
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

      dataByte.position = Vector2(
        laneCenterAtY(laneIndex, collectibleY),
        collectibleY,
      );

    spawnReservations.add(
      SpawnReservation(
        lane: laneIndex,
        startY: collectibleY,
        halfHeight: 40.0,
        spawnTime: gameTime,
        isCollectible: true,
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
        isCollectible: true,
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

    bonusChip.position = Vector2(
      laneCenterAtY(laneIndex, bonusChipY),
      bonusChipY,
    );

    // Reserve its position to prevent unwanted overlaps.
    spawnReservations.add(
      SpawnReservation(
        lane: laneIndex,
        startY: bonusChipY,
        halfHeight: bonusChipHalfHeight,
        spawnTime: gameTime,
        isCollectible: true,
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

  Future<void> restartGame() async {
    // Remove the Game Over overlay.
    overlays.remove('GameOver');

    // Reset the score and collected Data Bytes.
    health = 2;
    score = 0;
    dataBytesCollected = 0;
    distance = 0;
    gameTime = 0;

    // Reset spawning timers.
    spawnTimer = 0;
    collectibleTimer = 0;
    bonusChipTimer = 0;

    spawnReservations.clear();

    for (int i = 0; i < laneSafeUntil.length; i++) {
      laneSafeUntil[i] = 0.0;
    }

    // Remove remaining obstacles and collectibles.
    final oldObjects = children.where((component) =>
        component is GameObstacle || 
        component is GameCollectible).toList();

    for (final object in oldObjects) {
      object.removeFromParent();
    }

    // Reset the player's position and movement state.
    surferPlayer.resetPlayer();

    // Reset the score and distance displays.
    scoreNotifier.value = 0;
    distanceNotifier.value = 0;

    // Update the HUD to restore the health.
    overlays.remove('Hud');
    overlays.add('Hud');

    // Resume Gameplay.
    resumeEngine();
  }

  @override
  void resumeEngine() {
    super.resumeEngine();
    MusicManager.instance.play(MusicTrack.gameplay);
  }

}

class SpawnReservation {
  final int lane;
  final double startY;
  final double halfHeight;
  final double spawnTime;
  final bool isLaser;
  final bool isCollectible;

  SpawnReservation({
    required this.lane,
    required this.startY,
    required this.halfHeight,
    required this.spawnTime,
    this.isLaser = false,
    this.isCollectible = false,
  });

}