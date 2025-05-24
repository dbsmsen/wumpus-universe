import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  double _backgroundMusicVolume = 0.5;
  double _soundEffectVolume = 0.3;
  String _currentBackgroundMusic = 'sounds/grid_screen.wav';
  bool _isGameScreen = false;
  bool _isPlayingSoundEffect = false;
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  bool get isMusicPlaying => _isMusicPlaying;
  double get backgroundMusicVolume => _backgroundMusicVolume;
  double get soundEffectVolume => _soundEffectVolume;

  Future<void> initialize() async {
    try {
      print('Initializing AudioManager...');

      // Load saved volume and mute settings
      final prefs = await SharedPreferences.getInstance();
      _backgroundMusicVolume = prefs.getDouble('background_music_volume') ?? 0.5;
      _soundEffectVolume = prefs.getDouble('sound_effect_volume') ?? 0.3;
      _isMuted = prefs.getBool('is_muted') ?? false;

      // Initialize audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_isMuted ? 0 : _backgroundMusicVolume);
      await _audioPlayer.setSource(AssetSource(_currentBackgroundMusic));
      
      // Set initial state
      _isMusicPlaying = false;
      
      // Start playing if not muted and not on web
      if (!kIsWeb && !_isMuted) {
        await playBackgroundMusic();
      }
      
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
      _isMusicPlaying = false;
      _isMuted = true; // Default to muted on error
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying && !_isGameScreen && !_isPlayingSoundEffect && !_isMuted) {
      try {
        print('Attempting to play background music...');
        // Always re-initialize to ensure clean state
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(_backgroundMusicVolume);
        await _audioPlayer.setSource(AssetSource(_currentBackgroundMusic));
        
        // Small delay to ensure audio system is ready
        await Future.delayed(const Duration(milliseconds: 100));
        await _audioPlayer.resume();
        _isMusicPlaying = true;
        print('Background music started successfully');
      } catch (e) {
        print('Error playing background music: $e');
        _isMusicPlaying = false;
        // Try to recover by resetting the audio player
        try {
          await _audioPlayer.stop();
          await _audioPlayer.release();
        } catch (e2) {
          print('Error during recovery: $e2');
        }
      }
    } else {
      print('Skipping playback - Playing: $_isMusicPlaying, GameScreen: $_isGameScreen, SoundEffect: $_isPlayingSoundEffect, Muted: $_isMuted');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isMusicPlaying && !_isPlayingSoundEffect) {
      try {
        print('Attempting to pause background music...');
        await _audioPlayer.stop(); // Use stop instead of pause for more reliable state
        _isMusicPlaying = false;
        print('Background music stopped successfully');
      } catch (e) {
        print('Error stopping background music: $e');
        _isMusicPlaying = true; // Revert state if stop fails
      }
    }
  }

  Future<void> toggleMute() async {
    try {
      print('Current state - Muted: $_isMuted, Playing: $_isMusicPlaying');
      _isMuted = !_isMuted;
      print('Toggling mute state to: ${_isMuted ? 'muted' : 'unmuted'}');
      
      // Save mute state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_muted', _isMuted);

      if (_isMuted) {
        // When muting, stop the audio completely
        print('Stopping audio and setting volume to 0');
        await _audioPlayer.setVolume(0);
        await _audioPlayer.stop();
        _isMusicPlaying = false;
      } else {
        // When unmuting, reinitialize and start playing
        print('Unmuting: Setting volume and restarting playback');
        await _audioPlayer.setVolume(_backgroundMusicVolume);
        await _audioPlayer.setSource(AssetSource(_currentBackgroundMusic));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.resume();
        _isMusicPlaying = true;
      }
      print('Audio state updated - Muted: $_isMuted, Playing: $_isMusicPlaying');
    } catch (e) {
      print('Error toggling mute: $e');
      // Revert mute state if operation fails
      _isMuted = !_isMuted;
      print('Reverted mute state due to error');
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
