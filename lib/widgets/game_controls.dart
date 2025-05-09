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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_directionIcon(dir.Direction.up), size: 32),
                  onPressed: isGameOver || autoMoveEnabled
                      ? null
                      : () => onMove(dir.Direction.up),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_directionIcon(dir.Direction.left), size: 32),
                      onPressed: isGameOver || autoMoveEnabled
                          ? null
                          : () => onMove(dir.Direction.left),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: Icon(_directionIcon(dir.Direction.right), size: 32),
                      onPressed: isGameOver || autoMoveEnabled
                          ? null
                          : () => onMove(dir.Direction.right),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(_directionIcon(dir.Direction.down), size: 32),
                  onPressed: isGameOver || autoMoveEnabled
                      ? null
                      : () => onMove(dir.Direction.down),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
