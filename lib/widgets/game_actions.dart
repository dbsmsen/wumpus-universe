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
          Center(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  'Shoot Arrow',
                  Colors.red.shade300,
                  isGameOver || !hasArrow ? null : onShootArrow,
                  textColor: Colors.white,
                ),
                _buildActionButton(
                  'AI Solve',
                  Colors.purple.shade300,
                  isGameOver || autoMoveEnabled ? null : onAutoSolve,
                  textColor: Colors.white,
                ),
                if (isGameOver)
                  _buildActionButton(
                    'New Game',
                    Colors.green.shade300,
                    onNewGame,
                    textColor: Colors.white,
                  )
                else
                  _buildActionButton(
                    'Restart',
                    Colors.teal.shade300,
                    onRestart,
                    textColor: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed, {Color textColor = Colors.black}) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
