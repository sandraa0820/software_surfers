import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'software_surfers_game.dart';
import 'overlays/hud.dart';
import 'overlays/game_over.dart';
import 'overlays/main_menu.dart';
import 'overlays/how_to_play.dart';
import 'overlays/settings.dart';
import 'overlays/credits.dart';

// ---------------------------------------------------------------------------
// Music manager
// ---------------------------------------------------------------------------

enum MusicTrack { intro, gameplay, gameOver }

class MusicManager {
  MusicManager._();
  static final MusicManager instance = MusicManager._();

  final _soloud = SoLoud.instance;
  final Map<MusicTrack, AudioSource> _sources = {};

  SoundHandle? _currentHandle;
  MusicTrack? _currentTrack; // what is actually playing
  MusicTrack? _wantedTrack;  // what the game last asked for
  bool _ready = false;
  bool _enabled = true;
  bool _unlocked = false; // only needed if you added the web retryCurrent()

  bool get musicEnabled => _enabled;

  static const _prefsKey = 'musicEnabled';

  static const _paths = {
    MusicTrack.intro: 'assets/audio/intro.mp3',
    MusicTrack.gameplay: 'assets/audio/gameplay.mp3',
    MusicTrack.gameOver: 'assets/audio/game_over.mp3',
  };

  static const _loops = {
    MusicTrack.intro: true,
    MusicTrack.gameplay: true,
    MusicTrack.gameOver: false,
  };

  /// Never throws: if audio fails, the game still runs (silently).
  Future<void> init() async {
    try {
      // Load the saved music preference.
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? true;

      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      for (final entry in _paths.entries) {
        _sources[entry.key] = await _soloud.loadAsset(
          entry.value,
          mode: LoadMode.disk,
        );
      }
      _ready = true;

      // Play whatever the game asked for while we were loading.
      final wanted = _wantedTrack;
      if (wanted != null && _enabled) {
        play(wanted);
      }
    } catch (e, st) {
      debugPrint('MusicManager init failed: $e\n$st');
    }
  }

  void play(
    MusicTrack track, {
    Duration fade = const Duration(milliseconds: 800),
    double volume = 0.7,
  }) {
    _wantedTrack = track; // remember it even if music is off or not loaded yet
    if (!_enabled || !_ready) return;
    if (_currentTrack == track) return;
    _currentTrack = track;

    try {
      final old = _currentHandle;
      if (old != null) {
        _soloud.fadeVolume(old, 0, fade);
        _soloud.scheduleStop(old, fade);
      }

      final handle = _soloud.play(
        _sources[track]!,
        volume: 0,
        looping: _loops[track]!,
      );
      _soloud.fadeVolume(handle, volume, fade);
      _currentHandle = handle;
    } catch (e, st) {
      debugPrint('MusicManager play failed: $e\n$st');
    }
  }

  /// Turns music on or off. The choice is saved between launches.
  Future<void> setMusicEnabled(bool enabled) async {
    if (_enabled == enabled) return;
    _enabled = enabled;

    if (enabled) {
      // Resume whatever fits the current game state.
      final wanted = _wantedTrack;
      if (wanted != null) play(wanted);
    } else {
      stop();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, enabled);
    } catch (e) {
      debugPrint('Could not save music setting: $e');
    }
  }

  void stop({Duration fade = const Duration(milliseconds: 500)}) {
    final h = _currentHandle;
    if (h == null) return;
    _soloud.fadeVolume(h, 0, fade);
    _soloud.scheduleStop(h, fade);
    _currentHandle = null;
    _currentTrack = null;
  }

  void dispose() {
    _soloud.deinit();
  }

  // Keep this only if you added the web autoplay fix earlier.
  void retryCurrent() {
    if (_unlocked || !_ready || !_enabled) return;
    _unlocked = true;
    final track = _currentTrack;
    if (track == null) return;

    _currentTrack = null;
    final h = _currentHandle;
    if (h != null) {
      try {
        _soloud.stop(h);
      } catch (_) {}
      _currentHandle = null;
    }
    play(track);
  }
}

/// Starts [track] when this widget first appears in the tree.
class MusicOnShow extends StatefulWidget {
  final MusicTrack track;
  final Widget child;

  const MusicOnShow({super.key, required this.track, required this.child});

  @override
  State<MusicOnShow> createState() => _MusicOnShowState();
}

class _MusicOnShowState extends State<MusicOnShow> {
  @override
  void initState() {
    super.initState();
    MusicManager.instance.play(widget.track);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start audio in the background. Do NOT await it before runApp.
  MusicManager.instance.init();

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
          return MusicOnShow(
            track: MusicTrack.gameOver,
            child: GameOver(game: game),
          );
        },
        'MainMenu': (context, game) {
          return MusicOnShow(
            track: MusicTrack.intro,
            child: MainMenu(game: game),
          );
        },
        // Sub-menus keep the intro music going.
        'HowToPlay': (context, game) {
          return MusicOnShow(
            track: MusicTrack.intro,
            child: HowToPlay(game: game),
          );
        },
        'Settings': (context, game) {
          return MusicOnShow(
            track: MusicTrack.intro,
            child: Settings(game: game),
          );
        },
        'Credits': (context, game) {
          return MusicOnShow(
            track: MusicTrack.intro,
            child: Credits(game: game),
          );
        },
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}