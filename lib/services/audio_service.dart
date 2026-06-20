import 'package:audioplayers/audioplayers.dart';

/// Singleton service managing all audio in Puzzlify.
///
/// Audio files in assets/audio/:
///   splash_bg.wav   – looping ambient music on splash screen
///   game_bg.wav     – looping background music during gameplay
///   tile_pick.wav   – short click when starting a drag on an endpoint
///   tile_step.wav   – subtle tick on each grid cell entered while dragging
///   connect.wav     – satisfying "ding" when two endpoints are linked
///   win.wav         – victory fanfare on level complete
///   button.wav      – generic UI button tap
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  // ── Players ─────────────────────────────────────────────────────────
  final AudioPlayer _bgPlayer = AudioPlayer();   // Looping background music
  final AudioPlayer _sfxPlayer = AudioPlayer();  // One-shot sound effects

  bool _muted = false;
  bool get muted => _muted;

  // ── Init ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.35);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.setVolume(0.8);
  }

  // ── Mute toggle ──────────────────────────────────────────────────────

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) {
      await _bgPlayer.setVolume(0.0);
      await _sfxPlayer.setVolume(0.0);
    } else {
      await _bgPlayer.setVolume(0.35);
      await _sfxPlayer.setVolume(0.8);
    }
  }

  // ── Background music ─────────────────────────────────────────────────

  Future<void> playSplashMusic() async {
    await _playBg('audio/splash_bg.wav');
  }

  Future<void> playGameMusic() async {
    await _playBg('audio/game_bg.wav');
  }

  Future<void> stopMusic() async {
    try {
      await _bgPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playBg(String asset) async {
    try {
      await _bgPlayer.stop();
      await _bgPlayer.play(AssetSource(asset));
    } catch (_) {
      // Gracefully ignore if audio file is missing
    }
  }

  // ── Sound effects ────────────────────────────────────────────────────

  Future<void> playTilePick() async  => _playSfx('audio/tile_pick.wav');
  Future<void> playTileStep() async  => _playSfx('audio/tile_step.wav');
  Future<void> playConnect() async   => _playSfx('audio/connect.wav');
  Future<void> playWin() async       => _playSfx('audio/win.wav');
  Future<void> playButton() async    => _playSfx('audio/button.wav');

  Future<void> _playSfx(String asset) async {
    if (_muted) return;
    try {
      await _sfxPlayer.play(AssetSource(asset));
    } catch (_) {
      // Gracefully ignore if audio file is missing
    }
  }

  // ── Dispose ──────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
