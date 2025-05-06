import 'package:flutter/material.dart';
import 'game_screen.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Wumpus World!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'The Wumpus World is a simple world example that demonstrates knowledge-based agents and knowledge representation. Your goal is to navigate the cave, find the gold, and return to safety without falling into a pit or getting eaten by the Wumpus.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Here\'s what you need to know:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const InstructionItem(
              imagePath: 'assets/images/agent.png',
              text: 'You are the agent. Move through the grid to find the gold.',
            ),
            const InstructionItem(
              imagePath: 'assets/images/pit.png',
              text: 'Avoid pits! Falling into one ends the game.',
            ),
            const InstructionItem(
              imagePath: 'assets/images/wumpus.png',
              text: 'Beware of the Wumpus. It kills you if you enter its room.',
            ),
            const InstructionItem(
              imagePath: 'assets/images/gold.png',
              text: 'Find the gold and return to the start to win!',
            ),
            const SizedBox(height: 20),
            const Text(
              'Game Mechanics:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• The cave is a 4x4 grid with 16 rooms connected by passageways.\n'
                  '• The Wumpus can be killed by the agent if the agent faces it and shoots an arrow.\n'
                  '• Each room may contain a pit, a Wumpus, or gold.\n'
                  '• The agent senses: stench (near the Wumpus), breeze (near a pit), glitter (when gold is present), and bump (if the agent walks into a wall).\n'
                  '• The agent earns +1000 points for finding the gold and exiting the cave. The agent loses -1000 points for falling into a pit or being eaten by the Wumpus.\n',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              ),
              child: const Text("Let's Play!"),
            )
          ],
        ),
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String imagePath;
  final String text;

  const InstructionItem({super.key, required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
