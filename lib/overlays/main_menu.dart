import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class MainMenu extends StatelessWidget {
  final SoftwareSurfersGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isPortrait =
            constraints.maxHeight > constraints.maxWidth;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Dark background behind the artwork.
            const ColoredBox(
              color: Color(0xFF080A19),
            ),

            // Responsive Main Menu background.
            Image.asset(
              isPortrait
                  ? 'assets/images/menus/mainMenu_portrait.png'
                  : 'assets/images/menus/mainMenu_landscape.png',
              fit: BoxFit.fill,
            ),

          SafeArea(
              child: Align(
                alignment: isPortrait
                    ? const Alignment(0.0, 0.95)
                    : const Alignment(0.80, 0.65),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildHighScore(),
                      const SizedBox(height: 12),

                      buildPlayButton(),
                      const SizedBox(height: 10),

                      buildMenuButton(
                        label: 'HOW TO PLAY',
                        icon: Icons.sports_esports,
                        color: const Color(0xFF00E5FF),
                        onPressed: () {
                          game.overlays.remove('MainMenu');
                          game.overlays.add('HowToPlay');
                        },
                      ),
                      const SizedBox(height: 10),

                      buildMenuButton(
                        label: 'SETTINGS',
                        icon: Icons.settings,
                        color: const Color(0xFFFF69C8),
                        onPressed: () {
                          game.overlays.remove('MainMenu');
                          game.overlays.add('Settings');
                        },
                      ),
                      const SizedBox(height: 10),

                      buildMenuButton(
                        label: 'CREDITS',
                        icon: Icons.groups,
                        color: const Color(0xFFC59BFF),
                        onPressed: () {
                          game.overlays.remove('MainMenu');
                          game.overlays.add('Credits');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildHighScore() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xEE10152F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFD700),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '★ HIGH SCORE ★',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${game.highScore}',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlayButton() {
    return Container(
      width: 280,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x887C3AED),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          game.overlays.remove('MainMenu');
          game.restartGame();
        },
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          'PLAY',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7025C9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFC59BFF),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 280,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10152F),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: color,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}