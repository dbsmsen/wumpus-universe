import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  bool get isMusicPlaying => _isMusicPlaying;

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      if (await _audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(AssetSource('sounds/lolamoore.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }
      _isMusicPlaying = true;
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
      _isMusicPlaying = false;
    }
  }

  Future<void> toggleBackgroundMusic() async {
    if (_isMusicPlaying) {
      await stopBackgroundMusic();
    } else {
      await playBackgroundMusic();
    }
  }

  Future<void> playPitSound() async {
    await _audioPlayer.play(AssetSource('sounds/pit_fall.mp3'));
  }

  Future<void> playWumpusDeathSound() async {
    await _audioPlayer.play(AssetSource('sounds/wumpus_death.mp3'));
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
