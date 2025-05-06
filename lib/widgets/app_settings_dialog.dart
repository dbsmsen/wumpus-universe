import 'package:flutter/material.dart';

class AppSettingsDialog extends StatefulWidget {
  const AppSettingsDialog({super.key});

  @override
  State<AppSettingsDialog> createState() => _AppSettingsDialogState();
}

class _AppSettingsDialogState extends State<AppSettingsDialog> {
  bool _darkModeEnabled = true;
  bool _notificationsEnabled = true;
  bool _tutorialAutoShowEnabled = true;

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
              Colors.teal.shade600,
              Colors.teal.shade800,
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
              'App Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Dark Mode Toggle
            SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Switch between light and dark themes',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
              activeColor: Colors.amber,
            ),
            
            // Notifications Toggle
            SwitchListTile(
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Receive game updates and achievements',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: Colors.amber,
            ),
            
            // Tutorial Auto-show Toggle
            SwitchListTile(
              title: const Text(
                'Auto Show Tutorial',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Show tutorial automatically for new features',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              value: _tutorialAutoShowEnabled,
              onChanged: (bool value) {
                setState(() {
                  _tutorialAutoShowEnabled = value;
                });
              },
              activeColor: Colors.amber,
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save app settings logic
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

// Function to show the app settings dialog from outside the widget
void showAppSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AppSettingsDialog(),
  );
}
