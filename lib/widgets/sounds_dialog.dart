import 'package:flutter/material.dart';
import 'package:wumpus_universe/services/audio_manager.dart';

class SoundsDialog extends StatefulWidget {
  final AudioManager audioManager;
  final Function(double) onVolumeChanged;
  final bool isMusicPlaying;
  final VoidCallback onToggleMusic;

  const SoundsDialog({
    super.key,
    required this.audioManager,
    required this.onVolumeChanged,
    required this.isMusicPlaying,
    required this.onToggleMusic,
  });

  @override
  State<SoundsDialog> createState() => _SoundsDialogState();
}

class _SoundsDialogState extends State<SoundsDialog> {
  late double _volume;
  late bool _isMusicPlaying;

  @override
  void initState() {
    super.initState();
    _volume = widget.audioManager.backgroundMusicVolume;
    _isMusicPlaying = widget.isMusicPlaying;
  }

  void _handleVolumeChange(double value) {
    setState(() {
      _volume = value;
    });
    widget.onVolumeChanged(value);
  }

  void _handleMusicToggle(bool value) {
    setState(() {
      _isMusicPlaying = value;
    });
    widget.onToggleMusic();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sound Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Background Music'),
              Switch(
                value: _isMusicPlaying,
                onChanged: _handleMusicToggle,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.volume_down),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4.0,
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withOpacity(0.2),
                    activeTickMarkColor: Colors.blue,
                    inactiveTickMarkColor: Colors.grey[300],
                    tickMarkShape: const RoundSliderTickMarkShape(
                      tickMarkRadius: 4.0,
                    ),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16.0,
                    ),
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(_volume * 100).round()}%',
                    onChanged: _handleVolumeChange,
                  ),
                ),
              ),
              const Icon(Icons.volume_up),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Volume: ${(_volume * 100).round()}%',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
