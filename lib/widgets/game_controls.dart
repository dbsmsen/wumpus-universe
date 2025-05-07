import 'package:flutter/material.dart';
import '../models/direction.dart' as dir;

class GameControls extends StatelessWidget {
  final bool isGameOver;
  final bool autoMoveEnabled;
  final Function(dir.Direction) onMove;

  const GameControls({
    super.key,
    required this.isGameOver,
    required this.autoMoveEnabled,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movement Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_directionIcon(dir.Direction.up), size: 40),
                  onPressed: isGameOver || autoMoveEnabled
                      ? null
                      : () => onMove(dir.Direction.up),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_directionIcon(dir.Direction.left), size: 40),
                      onPressed: isGameOver || autoMoveEnabled
                          ? null
                          : () => onMove(dir.Direction.left),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 80),
                    IconButton(
                      icon: Icon(_directionIcon(dir.Direction.right), size: 40),
                      onPressed: isGameOver || autoMoveEnabled
                          ? null
                          : () => onMove(dir.Direction.right),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(_directionIcon(dir.Direction.down), size: 40),
                  onPressed: isGameOver || autoMoveEnabled
                      ? null
                      : () => onMove(dir.Direction.down),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _directionIcon(dir.Direction direction) {
    switch (direction) {
      case dir.Direction.up:
        return Icons.arrow_upward;
      case dir.Direction.right:
        return Icons.arrow_forward;
      case dir.Direction.down:
        return Icons.arrow_downward;
      case dir.Direction.left:
        return Icons.arrow_back;
    }
  }
}
