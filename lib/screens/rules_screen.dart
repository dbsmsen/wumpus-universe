import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules & Instructions'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Game Objective',
                'Find the gold and return to your starting position safely.',
                Icons.emoji_events,
              ),
              _buildSection(
                'Movement',
                'Use the arrow buttons to move in different directions. Plan your path carefully!',
                Icons.directions,
              ),
              _buildSection(
                'Dangers',
                'Watch out for pits and the Wumpus! They can end your game.',
                Icons.warning,
              ),
              _buildSection(
                'Senses',
                'Use your senses to detect dangers:\n• Breeze indicates a pit nearby\n• Stench means the Wumpus is close\n• Glitter appears when gold is in your room',
                Icons.sensors,
              ),
              _buildSection(
                'Combat',
                'You have one arrow to shoot the Wumpus. Use it wisely!',
                Icons.arrow_forward,
              ),
              _buildSection(
                'Scoring',
                '• +1000 points for finding gold\n• +500 points for killing the Wumpus\n• -1000 points for falling into a pit or being eaten\n• -10 points for each move',
                Icons.score,
              ),
              _buildSection(
                'Tips',
                '• Always check for breeze and stench before moving\n• Plan your path to minimize moves\n• Remember where you started\n• Keep track of explored areas',
                Icons.lightbulb,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
