import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'software_surfers_game.dart';
import 'overlays/hud.dart';
import 'overlays/game_over.dart';

void main() {
  runApp(
    GameWidget<SoftwareSurfersGame>(
      game: SoftwareSurfersGame(),
      overlayBuilderMap: {
        'Hud': (context, game) {
          return Stack(
            children: [
              GameHud(game: game),
            ],
          );
        },
        'GameOver': (context, game) {
          return GameOver(game: game);
        },
      },
      initialActiveOverlays: const ['Hud'],
    ),
  );
}
