import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class GameHud extends StatelessWidget {
  final SoftwareSurfersGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      // Neon pink hearts.
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: List.generate(2, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < game.health
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: const Color(0xFFFF69C8),
                  size: 36,
                  shadows: const [
                    Shadow(
                      color: Color(0xFFFF1493),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Color(0xFFFF00AA),
                      blurRadius: 22,
                    ),
                    Shadow(
                      color: Color(0xFFFF00FF),
                      blurRadius: 35,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Distance counter.
        Positioned(
          top: 20,
          right: 20,
          child: ValueListenableBuilder<int>(
            valueListenable: game.distanceNotifier,
            builder: (context, distance, child) {
              return Text(
                '$distance m',
                    style: const TextStyle(
                      color: Color(0xFFFF69C8),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            color: Color(0xFF080D24),
                            offset: Offset(2, 2),
                            blurRadius: 3,
                        ),

                        // Neon pink glow.
                        Shadow(
                          color: Color(0xFFFF1493),
                          blurRadius: 12,
                        ),
                        Shadow(
                          color: Color(0xFFFF00AA),
                          blurRadius: 12,
                        ),
                      ],
                    ),
              );
            },
          ),
        ),

        // Data Byte score counter.
        Positioned(
          top: 58,
          right: 20,
          child: ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (context, score, child) {
              return Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    // Dark shadow for readability.
                    Shadow(
                      color: Color(0xFF080D24),
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),

                    // Golden glow.
                    Shadow(
                      color: Color(0xFFFFD700),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Color(0xFFFFA500),
                      blurRadius: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
