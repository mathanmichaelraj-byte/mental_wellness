import 'package:audioplayers/audioplayers.dart';

/// Wraps [AudioPlayer] for the three therapeutic audio tracks.
class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playCalm() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/calm.mp3'));
  }

  Future<void> playBreathing() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/rain.mp3'));
  }

  Future<void> playNature() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/nature.mp3'));
  }

  Future<void> pause()                => _player.pause();
  Future<void> stop()                 => _player.stop();
  Future<void> setVolume(double v)    => _player.setVolume(v);
  void         dispose()              => _player.dispose();
}
