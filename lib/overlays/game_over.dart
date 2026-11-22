
import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class GameOver extends StatelessWidget {
  final SoftwareSurfersGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Neon pink Game Over title.
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF69C8),
                  shadows: [
                    Shadow(
                      color: Color(0xFFFF1493),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Defeated runner illustration.
              Image.asset(
                'assets/images/game_over.png',
                width: 260,
                height: 190,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              // Game statistics.
              Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF10152F),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFF69C8),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FF1493),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total score.
                    buildStat(
                      'SCORE',
                      '${game.score}',
                      const Color(0xFFC59BFF),
                    ),

                    const SizedBox(height: 15),

                    // Distance traveled.
                    buildStat(
                      'DISTANCE',
                      '${game.distance.toInt()} m',
                      const Color(0xFFFF69C8),
                    ),

                    const SizedBox(height: 15),

                    // Data Bytes collected.
                    buildStat(
                      'DATA BYTES',
                      '${game.dataBytesCollected}',
                      const Color(0xFFFFD700),
                    ),

                    const SizedBox(height: 15),

                    // Highest score achieved.
                    buildStat(
                      'HIGH SCORE',
                      '${game.highScore}',
                      const Color(0xFFFFD700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a row for each game statistic.
  Widget buildStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
