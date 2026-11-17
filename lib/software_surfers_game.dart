import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';


import 'world/game_track.dart';
import 'world/computer_background.dart';
import 'player/surfer_player.dart';

class SoftwareSurfersGame extends FlameGame with HasKeyboardHandlerComponents {
  late SurferPlayer surferPlayer;

  @override
  Color backgroundColor() => const Color(0xFF10152F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final background = SpriteComponent(
      sprite: await loadSprite('softwares_background.png'),
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
  }

}