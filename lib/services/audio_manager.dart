import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  double _backgroundMusicVolume = 0.5;
  double _soundEffectVolume = 0.3;
  String? _currentBackgroundMusic;
  bool _isGameScreen = false;
  bool _isPlayingSoundEffect = false;

  bool get isMusicPlaying => _isMusicPlaying;
  double get backgroundMusicVolume => _backgroundMusicVolume;
  double get soundEffectVolume => _soundEffectVolume;

  Future<void> initialize() async {
    try {
      print('Initializing AudioManager...');

      // Load saved volume settings
      final prefs = await SharedPreferences.getInstance();
      _backgroundMusicVolume =
          prefs.getDouble('background_music_volume') ?? 0.5;
      _soundEffectVolume = prefs.getDouble('sound_effect_volume') ?? 0.3;

      // Initialize audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_backgroundMusicVolume);
      await _audioPlayer.setSource(AssetSource('sounds/grid_screen.wav'));
      _currentBackgroundMusic = 'sounds/grid_screen.wav';
      await _audioPlayer.resume();

      _isMusicPlaying = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying && !_isGameScreen && !_isPlayingSoundEffect) {
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(_backgroundMusicVolume);
        await _audioPlayer.resume();
        _isMusicPlaying = true;
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isMusicPlaying && !_isPlayingSoundEffect) {
      try {
        await _audioPlayer.pause();
        _isMusicPlaying = false;
      } catch (e) {
        print('Error pausing background music: $e');
      }
    }
  }

  Future<void> playSoundEffect(String soundFile) async {
    if (_isPlayingSoundEffect) return;

    try {
      _isPlayingSoundEffect = true;

      // Store current state
      final currentVolume = _backgroundMusicVolume;
      final currentSource = _currentBackgroundMusic;
      final currentPosition = await _audioPlayer.getCurrentPosition();
      final wasPlaying = _isMusicPlaying;

      // Play sound effect
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(_soundEffectVolume);
      await _audioPlayer.setSource(AssetSource(soundFile));
      await _audioPlayer.resume();

      // Wait for sound effect to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Restore background music if it was playing
      if (wasPlaying && !_isGameScreen) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        if (currentSource != null) {
          await _audioPlayer.setSource(AssetSource(currentSource));
          if (currentPosition != null) {
            await _audioPlayer.seek(currentPosition);
          }
        }
        await _audioPlayer.setVolume(currentVolume);
        await _audioPlayer.resume();
      }

      _isPlayingSoundEffect = false;
    } catch (e) {
      print('Error playing sound effect: $e');
      _isPlayingSoundEffect = false;
    }
  }

  Future<void> setBackgroundMusicVolume(double volume) async {
    try {
      _backgroundMusicVolume = volume;
      if (_isMusicPlaying && !_isPlayingSoundEffect) {
        await _audioPlayer.setVolume(volume);
      }

      // Save volume setting
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('background_music_volume', volume);
    } catch (e) {
      print('Error setting background music volume: $e');
    }
  }

  Future<void> setSoundEffectVolume(double volume) async {
    try {
      _soundEffectVolume = volume;
      // Save volume setting
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sound_effect_volume', volume);
    } catch (e) {
      print('Error setting sound effect volume: $e');
    }
  }

  Future<void> enterGameScreen() async {
    _isGameScreen = true;
    await pauseBackgroundMusic();
  }

  Future<void> exitGameScreen() async {
    _isGameScreen = false;
    await playBackgroundMusic();
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing AudioManager: $e');
    }
  }
}
