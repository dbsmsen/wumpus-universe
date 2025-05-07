import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/agent.dart';
import '../models/grid.dart';

class GameGrid extends StatefulWidget {
  final Grid grid;
  final Agent agent;
  final bool Function(int x, int y) isNeighbor;
  final Map<String, AnimationController> cellAnimations;

  const GameGrid({
    super.key,
    required this.grid,
    required this.agent,
    required this.isNeighbor,
    required this.cellAnimations,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.grid.columns,
      ),
      itemCount: widget.grid.rows * widget.grid.columns,
      itemBuilder: (_, index) {
        final x = index % widget.grid.columns;
        final y = index ~/ widget.grid.columns;
        return _buildCell(x, y);
      },
    );
  }

  Widget _buildCell(int x, int y) {
    final cell = widget.grid.cells[y][x];
    final isAgentHere = x == widget.agent.x && y == widget.agent.y;
    final isVisible = widget.isNeighbor(x, y) || isAgentHere;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isVisible ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isVisible) ...[
            // Only show stench and breeze in neighboring cells
            if (!isAgentHere) ...[
              if (cell.stench)
                _buildAnimatedImage('assets/images/stench.png', 'stench'),
              if (cell.breeze)
                _buildAnimatedImage('assets/images/breeze.png', 'breeze'),
            ],
            // Only show hazards and gold when agent is on the cell
            if (isAgentHere) ...[
              if (cell.hasPit)
                _buildAnimatedImage('assets/images/pit.png', 'pit'),
              if (cell.hasWumpus && !cell.isWumpusDead)
                _buildAnimatedImage('assets/images/wumpus.png', 'wumpus'),
              if (cell.hasWumpus && cell.isWumpusDead)
                _buildAnimatedImage(
                    'assets/images/wumpus_dead.png', 'wumpus_dead'),
              if (cell.hasGold)
                _buildAnimatedImage('assets/images/gold.png', 'gold'),
              if (cell.glitter)
                _buildAnimatedImage('assets/images/glitter.png', 'glitter'),
            ],
          ],
          if (isAgentHere) _buildAnimatedAgent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedImage(String imagePath, String key) {
    if (!widget.cellAnimations.containsKey(key)) {
      widget.cellAnimations[key] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);
    }

    return FadeTransition(
      opacity: widget.cellAnimations[key]!,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAnimatedAgent() {
    return Image.asset(
      'assets/images/agent.png',
      fit: BoxFit.contain,
    );
  }
}
