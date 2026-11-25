import 'package:flutter/material.dart';

import '../software_surfers_game.dart';

class Settings extends StatefulWidget {
  final SoftwareSurfersGame game;

  const Settings({super.key, required this.game});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;
  double masterVolume = 1.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF080A19),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SETTINGS',
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
                  'CUSTOMIZE YOUR EXPERIENCE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC59BFF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 25),

                buildAudioSettings(),

                const SizedBox(height: 25),

                buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAudioSettings() {
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
          const Row(
            children: [
              Icon(
                Icons.volume_up,
                color: Color(0xFF00E5FF),
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'AUDIO',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          buildAudioSwitch(
            icon: Icons.music_note,
            title: 'Background Music',
            description: 'Enable or disable music',
            value: musicEnabled,
            onChanged: (value) {
              setState(() {
                musicEnabled = value;
              });
            },
          ),

          const Divider(color: Colors.white12),

          buildAudioSwitch(
            icon: Icons.graphic_eq,
            title: 'Sound Effects',
            description: 'Enable or disable gameplay sounds',
            value: soundEffectsEnabled,
            onChanged: (value) {
              setState(() {
                soundEffectsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildAudioSwitch({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFC59BFF),
            size: 30,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
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

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF7025C9),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: const Color(0xFF30354F),
          ),
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
          widget.game.overlays.remove('Settings');
          widget.game.overlays.add('MainMenu');
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
}