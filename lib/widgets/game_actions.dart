import 'package:flutter/material.dart';

class GameActions extends StatelessWidget {
  final bool isGameOver;
  final bool autoMoveEnabled;
  final bool hasArrow;
  final VoidCallback onShootArrow;
  final VoidCallback onAutoSolve;
  final VoidCallback onNewGame;
  final VoidCallback onRestart;

  const GameActions({
    super.key,
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
    return Container(
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
                  color: Colors.green.shade300.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.sports_esports,
                    color: Colors.green.shade300, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Game Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                'Shoot Arrow',
                Colors.red.shade100,
                isGameOver || !hasArrow ? null : onShootArrow,
              ),
              _buildActionButton(
                'AI Solve',
                Colors.purple.shade100,
                isGameOver || autoMoveEnabled ? null : onAutoSolve,
              ),
              if (isGameOver)
                _buildActionButton(
                  'New Game',
                  Colors.green.shade100,
                  onNewGame,
                ),
              _buildActionButton(
                'Restart',
                Colors.amber.shade100,
                onRestart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(text),
    );
  }
}
