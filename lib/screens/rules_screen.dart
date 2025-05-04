import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black.withOpacity(0.1),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Rules & Instructions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Game Objective',
                    'Find the gold and return to your starting position safely.',
                    Icons.emoji_events,
                    Colors.amber.shade300,
                  ),
                  _buildSection(
                    'Movement',
                    'Use the arrow buttons to move in different directions. Plan your path carefully!',
                    Icons.directions,
                    Colors.green.shade300,
                  ),
                  _buildSection(
                    'Dangers',
                    'Watch out for pits and the Wumpus! They can end your game.',
                    Icons.warning,
                    Colors.red.shade300,
                  ),
                  _buildSection(
                    'Senses',
                    'Use your senses to detect dangers:\n• Breeze indicates a pit nearby\n• Stench means the Wumpus is close\n• Glitter appears when gold is in your room',
                    Icons.sensors,
                    Colors.blue.shade300,
                  ),
                  _buildSection(
                    'Combat',
                    'You have one arrow to shoot the Wumpus. Use it wisely!',
                    Icons.arrow_forward,
                    Colors.purple.shade300,
                  ),
                  _buildSection(
                    'Scoring',
                    '• +1000 points for finding gold\n• +500 points for killing the Wumpus\n• -1000 points for falling into a pit or being eaten\n• -10 points for each move',
                    Icons.score,
                    Colors.teal.shade300,
                  ),
                  _buildSection(
                    'Tips',
                    '• Always check for breeze and stench before moving\n• Plan your path to minimize moves\n• Remember where you started\n• Keep track of explored areas',
                    Icons.lightbulb,
                    Colors.orange.shade300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
