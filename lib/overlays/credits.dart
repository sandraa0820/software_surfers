import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class Credits extends StatelessWidget {
  final SoftwareSurfersGame game;

  const Credits({super.key, required this.game});

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
                  'SOFTWARE',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Color(0xFF00E5FF),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),

                const Text(
                  'SURFERS',
                  style: TextStyle(
                    color: Color(0xFFFF69C8),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFF69C8),
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

                buildDevelopmentTeam(),

                const SizedBox(height: 20),

                buildTechnologies(),

                const SizedBox(height: 25),

                const Text(
                  'THANK YOU FOR PLAYING!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Color(0x88FFD700),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Keep running. Keep debugging.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC59BFF),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 25),

                buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDevelopmentTeam() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10152F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC59BFF),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55C59BFF),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups,
                color: Color(0xFFC59BFF),
                size: 26,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'DEVELOPMENT TEAM',
                  style: TextStyle(
                    color: Color(0xFFC59BFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          buildTeamMember(
            name: 'Sandra Luna',
            contribution:
                'Core Gameplay • Game Design • UI & Menus • '
                'Game Assets • Scoring System • Mobile Controls',
          ),

          const Divider(color: Colors.white12),

          buildTeamMember(
            name: 'Justin Alcaraz',
          ),

          const Divider(color: Colors.white12),

          buildTeamMember(
            name: 'Catherine Lopez-Ruiz',
          ),

          const Divider(color: Colors.white12),

          buildTeamMember(
            name: 'Jade McClain',
          ),
        ],
      ),
    );
  }

  Widget buildTeamMember({
    required String name,
    String contribution = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          if (contribution.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              contribution,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return Container(
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x887C3AED),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          game.overlays.remove('Credits');
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

  Widget buildTechnologies() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10152F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00E5FF),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4400E5FF),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BUILT WITH',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTechnology(
                name: 'Flutter',
                logo: const FlutterLogo(size: 40),
              ),

              buildTechnology(
                name: 'Flame',
                logo: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFF9E44),
                  size: 40,
                ),
              ),

              buildTechnology(
                name: 'Dart',
                logo: const Icon(
                  Icons.code,
                  color: Color(0xFF00E5FF),
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTechnology({
    required String name,
    required Widget logo,
  }) {
    return Column(
      children: [
        logo,

        const SizedBox(height: 8),

        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}