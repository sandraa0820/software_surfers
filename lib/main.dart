import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'software_surfers_game.dart';
import 'overlays/hud.dart';
import 'overlays/game_over.dart';
import 'overlays/main_menu.dart';
import 'overlays/how_to_play.dart';
import 'overlays/settings.dart';
import 'overlays/credits.dart';

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
        'MainMenu': (context, game) {
          return MainMenu(game: game);
        },
        'HowToPlay': (context, game) {
          return HowToPlay(game: game);
        },
        'Settings': (context, game) {
          return Settings(game: game);
        },
        'Credits': (context, game) {
          return Credits(game: game);
        },
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
