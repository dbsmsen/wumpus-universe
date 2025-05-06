import 'package:flutter/material.dart';

class GameAboutDialog extends StatelessWidget {
  const GameAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About Wumpus Universe'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wumpus Universe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Wumpus Universe is an exciting adventure game where you navigate through a cave system to find gold while avoiding dangers. Use your wits and senses to survive and achieve the highest score!',
            ),
            SizedBox(height: 16),
            Text(
              'Developed by:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Debsoomonto Sen'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
