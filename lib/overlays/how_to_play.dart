import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class HowToPlay extends StatelessWidget {
  final SoftwareSurfersGame game;

  const HowToPlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080A19),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HOW TO PLAY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Color(0xFF00E5FF),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'RUN. DODGE. DEBUG.',
                  style: TextStyle(
                    color: Color(0xFFC59BFF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 25),

                buildSection(
                  title: 'CONTROLS',
                  icon: Icons.sports_esports,
                  color: const Color(0xFF00E5FF),
                  content: Column(
                    children: [
                      buildControlRow(
                        Icons.arrow_back,
                        'Left Arrow',
                        'Swipe Left',
                        'Move Left',
                      ),
                      buildControlRow(
                        Icons.arrow_forward,
                        'Right Arrow',
                        'Swipe Right',
                        'Move Right',
                      ),
                      buildControlRow(
                        Icons.arrow_upward,
                        'Up Arrow',
                        'Swipe Up',
                        'Jump',
                      ),
                      buildControlRow(
                        Icons.arrow_downward,
                        'Down Arrow',
                        'Swipe Down',
                        'Slide',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                buildSection(
                  title: 'COLLECTIBLES',
                  icon: Icons.monetization_on,
                  color: const Color(0xFFFFD700),
                  content: Column(
                    children: [
                      buildCollectibleRow(
                        imagePath: 'assets/images/collectibles/data_byte.png',
                        name: 'Data Bytes',
                        description: 'Collect golden Data Bytes to increase your score.',
                        points: '+1',
                        color: const Color(0xFFFFD700),
                      ),

                      const Divider(color: Colors.white12),

                      buildCollectibleRow(
                        imagePath: 'assets/images/collectibles/bonus_chip.png',
                        name: 'Bonus Chips',
                        description: 'Collect rare Bonus Chips for extra points.',
                        points: '+20',
                        color: const Color(0xFFC59BFF),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                buildSection(
                  title: 'OBSTACLES',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFF69C8),
                  content: Column(
                    children: [
                      buildObstacleRow(
                        imagePath: 'assets/images/obstacles/bug.png',
                        name: 'Bug',
                        description:
                            'Jump over the bug or switch lanes to avoid it.',
                      ),

                      const Divider(color: Colors.white12),

                      buildObstacleRow(
                        imagePath: 'assets/images/obstacles/virus.png',
                        name: 'Virus',
                        description:
                            'Jump over the virus or switch lanes to avoid it.',
                      ),

                      const Divider(color: Colors.white12),

                      buildObstacleRow(
                        imagePath: 'assets/images/obstacles/error.png',
                        name: 'Error',
                        description:
                            'Jump over the error or switch lanes to avoid it.',
                      ),

                      const Divider(color: Colors.white12),

                      buildObstacleRow(
                        imagePath: 'assets/images/obstacles/server_block.png',
                        name: 'Server Block',
                        description:
                            'Switch lanes to avoid the server block. '
                            'You cannot jump over it.',
                      ),

                      const Divider(color: Colors.white12),

                      buildObstacleRow(
                        imagePath: 'assets/images/obstacles/barrier.png',
                        name: 'Laser Barrier',
                        description:
                            'Covers all three lanes! Slide underneath '
                            'the laser to avoid taking damage.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                buildSection(
                  title: 'HEALTH & SURVIVAL',
                  icon: Icons.shield,
                  color: const Color(0xFFC59BFF),
                  content: Column(
                    children: [
                      buildSurvivalRow(
                        leading: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Color(0xFFFF69C8),
                              size: 26,
                            ),
                            Icon(
                              Icons.favorite,
                              color: Color(0xFFFF69C8),
                              size: 26,
                            ),
                          ],
                        ),
                        name: 'Health',
                        description:
                            'You start with two hearts. Hitting an obstacle '
                            'costs one heart. Lose both and it\'s Game Over!',
                        color: const Color(0xFFFF69C8),
                      ),

                      const Divider(color: Colors.white12),

                      buildSurvivalRow(
                        leading: const Icon(
                          Icons.route,
                          color: Color(0xFF00E5FF),
                          size: 42,
                        ),
                        name: 'Distance',
                        description:
                            'Survive as long as possible and increase '
                            'your distance traveled.',
                        color: const Color(0xFF00E5FF),
                      ),

                      const Divider(color: Colors.white12),

                      buildSurvivalRow(
                        leading: const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFD700),
                          size: 42,
                        ),
                        name: 'High Score',
                        description:
                            'Collect Data Bytes and Bonus Chips to beat '
                            'your high score. Your best score is '
                            'automatically saved!',
                        color: const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed: () {
                    game.overlays.remove('HowToPlay');
                    game.overlays.add('MainMenu');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'BACK TO MAIN MENU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7025C9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(280, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFC59BFF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10152F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget buildControlRow(
    IconData icon,
    String keyboard,
    String swipe,
    String action,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF080A19),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00E5FF),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00E5FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$keyboard / $swipe',
                  style: const TextStyle(
                    color: Color(0xFFC59BFF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }  

  Widget buildCollectibleRow({
    required String imagePath,
    required String name,
    required String description,
    required String points,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            points,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildObstacleRow({
    required String imagePath,
    required String name,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFFF69C8),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSurvivalRow({
    required Widget leading,
    required String name,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Center(child: leading),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}