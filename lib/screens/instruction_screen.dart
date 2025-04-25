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
          children: [
            Expanded(
              child: ListView(
                children: const [
                  InstructionItem(
                    imagePath: 'assets/images/player.png',
                    text: 'You are the agent. Move through the grid to find the gold.',
                  ),
                  InstructionItem(
                    imagePath: 'assets/images/pit.png',
                    text: 'Avoid pits! Falling into one ends the game.',
                  ),
                  InstructionItem(
                    imagePath: 'assets/images/wumpus.png',
                    text: 'Beware of the Wumpus. It kills you if you enter its cell.',
                  ),
                  InstructionItem(
                    imagePath: 'assets/images/gold.png',
                    text: 'Find the gold and return to the start to win!',
                  ),
                ],
              ),
            ),
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

  const InstructionItem({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16)))
        ],
      ),
    );
  }
}
