import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';


import 'player/surfer_player.dart';

class SoftwareSurfersGame extends FlameGame with HasKeyboardHandlerComponents {
  late SurferPlayer surferPlayer;

  @override
  Color backgroundColor() => const Color(0xFF10152F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate the width of each lane
    double laneWidth = size.x / 3;

    surferPlayer = SurferPlayer(laneWidth: laneWidth);

    surferPlayer.position = Vector2(
      size.x / 2,
      size.y * 0.75,
    );

    await add(surferPlayer);
  }

}