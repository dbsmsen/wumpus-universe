import 'package:flutter/material.dart';
import '../models/agent.dart';

class GameInfoPanel extends StatelessWidget {
  final Agent agent;
  final String gameMessage;
  final Duration gameDuration;
  final bool hasWon;
  final bool isGameOver;
  final bool autoMoveEnabled;
  final bool hasArrow;
  final VoidCallback onShootArrow;
  final VoidCallback onAutoSolve;
  final VoidCallback onNewGame;
  final VoidCallback onRestart;

  const GameInfoPanel({
    super.key,
    required this.agent,
    required this.gameMessage,
    required this.gameDuration,
    required this.hasWon,
    required this.isGameOver,
    required this.autoMoveEnabled,
    required this.hasArrow,
    required this.onShootArrow,
    required this.onAutoSolve,
    required this.onNewGame,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Game Status & Controls',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Game Status',
                  'Score: ${agent.score}\nMoves: ${agent.moves}\nTime: ${_formatDuration(gameDuration)}',
                  Icons.info,
                  Colors.blue.shade300,
                ),
                if (gameMessage.isNotEmpty)
                  _buildSection(
                    'Message',
                    gameMessage,
                    hasWon ? Icons.emoji_events : Icons.warning,
                    hasWon ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                _buildSection(
                  'Controls',
                  'Use arrow buttons to move\nShoot arrow to kill Wumpus',
                  Icons.gamepad,
                  Colors.purple.shade300,
                ),
                _buildSection(
                  'Tips',
                  '\u2022 Watch for breeze and stench\n\u2022 Plan your path carefully\n\u2022 Remember your starting point',
                  Icons.lightbulb,
                  Colors.orange.shade300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
