import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  final AudioPlayer _player = AudioPlayer();

  AudioService._init();

  Future<void> playCalm() async {
    await _player.play(AssetSource('audio/calm.mp3'));
  }

  Future<void> playBreathing() async {
    await _player.play(AssetSource('audio/breathing.mp3'));
  }

  Future<void> playNature() async {
    await _player.play(AssetSource('audio/nature.mp3'));
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}
