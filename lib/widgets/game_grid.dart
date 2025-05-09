import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/agent.dart';
import '../models/grid.dart';

class GameGrid extends StatefulWidget {
  final Grid grid;
  final Agent agent;
  final bool Function(int, int) isNeighbor;
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
  void dispose() {
    // Dispose all animation controllers
    widget.cellAnimations.values.forEach((controller) {
      controller.dispose();
    });
    widget.cellAnimations.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum possible cell size based on available space
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        // Calculate cell size based on grid dimensions and available space
        final cellWidth = maxWidth / widget.grid.columns;
        final cellHeight = maxHeight / widget.grid.rows;

        // Use the smaller of the two to maintain square cells
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        // Calculate the total grid size
        final gridWidth = cellSize * widget.grid.columns;
        final gridHeight = cellSize * widget.grid.rows;

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.grid.columns,
                childAspectRatio: 1.0,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: widget.grid.rows * widget.grid.columns,
              itemBuilder: (context, index) {
                final x = index % widget.grid.columns;
                final y = index ~/ widget.grid.columns;
                return _buildCell(x, y);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int x, int y) {
    final cell = widget.grid.cells[y][x];
    final isAgentHere = x == widget.agent.x && y == widget.agent.y;
    final isVisible = isAgentHere ||
        cell.visited ||
        widget.isNeighbor(x, y) ||
        cell.isRevealed;

    return Container(
      decoration: BoxDecoration(
        color: isVisible ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVisible) ...[
            // Only show stench and breeze in neighboring cells
            if (!isAgentHere) ...[
              if (cell.stench)
                _buildAnimatedImage('assets/images/stench.png', 'stench_$x$y'),
              if (cell.breeze)
                _buildAnimatedImage('assets/images/breeze.png', 'breeze_$x$y'),
            ],
            // Only show hazards and gold when agent is on the cell
            if (isAgentHere) ...[
              if (cell.hasPit)
                _buildAnimatedImage('assets/images/pit.png', 'pit_$x$y'),
              if (cell.hasWumpus && !cell.isWumpusDead)
                _buildAnimatedImage('assets/images/wumpus.png', 'wumpus_$x$y'),
              if (cell.hasWumpus && cell.isWumpusDead)
                _buildAnimatedImage(
                    'assets/images/wumpus_dead.png', 'wumpus_dead_$x$y'),
              if (cell.hasGold)
                _buildAnimatedImage('assets/images/gold.png', 'gold_$x$y'),
              if (cell.glitter)
                _buildAnimatedImage(
                    'assets/images/glitter.png', 'glitter_$x$y'),
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
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAnimatedAgent() {
    const agentKey = 'agent';
    if (!widget.cellAnimations.containsKey(agentKey)) {
      widget.cellAnimations[agentKey] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);
    }

    return FadeTransition(
      opacity: widget.cellAnimations[agentKey]!,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          'assets/images/agent.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
