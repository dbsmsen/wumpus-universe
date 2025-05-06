import 'package:flutter/material.dart';

class SoundsDialog extends StatefulWidget {
  const SoundsDialog({super.key});

  @override
  State<SoundsDialog> createState() => _SoundsDialogState();
}

class _SoundsDialogState extends State<SoundsDialog> {
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  double _backgroundMusicVolume = 0.5;
  double _soundEffectsVolume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sound Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Background Music Toggle
            SwitchListTile(
              title: const Text(
                'Background Music',
                style: TextStyle(color: Colors.white),
              ),
              value: _backgroundMusicEnabled,
              onChanged: (bool value) {
                setState(() {
                  _backgroundMusicEnabled = value;
                });
              },
              activeColor: Colors.amber,
            ),
            
            // Background Music Volume Slider
            if (_backgroundMusicEnabled)
              Slider(
                value: _backgroundMusicVolume,
                onChanged: (double value) {
                  setState(() {
                    _backgroundMusicVolume = value;
                  });
                },
                activeColor: Colors.amber,
                inactiveColor: Colors.white.withOpacity(0.3),
                min: 0.0,
                max: 1.0,
              ),
            
            // Sound Effects Toggle
            SwitchListTile(
              title: const Text(
                'Sound Effects',
                style: TextStyle(color: Colors.white),
              ),
              value: _soundEffectsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _soundEffectsEnabled = value;
                });
              },
              activeColor: Colors.amber,
            ),
            
            // Sound Effects Volume Slider
            if (_soundEffectsEnabled)
              Slider(
                value: _soundEffectsVolume,
                onChanged: (double value) {
                  setState(() {
                    _soundEffectsVolume = value;
                  });
                },
                activeColor: Colors.amber,
                inactiveColor: Colors.white.withOpacity(0.3),
                min: 0.0,
                max: 1.0,
              ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save sound settings logic
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show the sounds dialog from outside the widget
void showSoundsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const SoundsDialog(),
  );
}
