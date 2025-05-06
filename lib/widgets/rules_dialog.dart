import 'package:flutter/material.dart';

class RulesDialog extends StatelessWidget {
  const RulesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Rules'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Basic Rules:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• Navigate through the cave system to find gold'),
            Text('• Avoid pits and the Wumpus'),
            Text('• Use your senses to detect dangers'),
            Text('• Return to the starting position after finding gold'),
            SizedBox(height: 16),
            Text(
              'Scoring:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• +1000 points for successful gold retrieval'),
            Text('• -1000 points for falling into a pit or being eaten'),
            Text('• -10 points for each move'),
            Text('• -100 points for shooting an arrow'),
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
