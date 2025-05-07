import 'dart:async';
import 'dart:math';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;

class WumpusAISolver {
  final Agent agent;
  final List<List<Cell>> grid;
  final int rows;
  final int columns;

  WumpusAISolver(
      {required this.agent,
      required this.grid,
      required this.rows,
      required this.columns});

  // Check if a cell is safe to move to based on sensory information
  bool _isSafeCell(int x, int y) {
    // Check bounds
    if (x < 0 || x >= columns || y < 0 || y >= rows) return false;

    // Check for hazards
    final cell = grid[y][x];
    if (cell.hasPit || (cell.hasWumpus && !cell.isWumpusDead)) return false;

    // Check if cell has been visited and is safe
    if (cell.visited && cell.safe) return true;

    // Check neighboring cells for hazards
    bool hasStench = false;
    bool hasBreeze = false;
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < columns && ny >= 0 && ny < rows) {
          if (grid[ny][nx].stench) hasStench = true;
          if (grid[ny][nx].breeze) hasBreeze = true;
        }
      }
    }

    // If no stench or breeze, cell is safe
    if (!hasStench && !hasBreeze) {
      cell.safe = true;
      return true;
    }

    return false;
  }

  // Find the Wumpus location based on stench
  (int, int)? _findWumpusLocation() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        if (grid[y][x].hasWumpus && !grid[y][x].isWumpusDead) {
          return (x, y);
        }
      }
    }
    return null;
  }

  // Find the gold's location in the grid
  (int, int) _findGoldLocation() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        if (grid[y][x].hasGold) {
          return (x, y);
        }
      }
    }
    return (-1, -1);
  }

  // Find the shortest safe path using A* algorithm
  List<dir.Direction> _findShortestSafePath(
      int startX, int startY, int targetX, int targetY) {
    // Possible move directions
    final directions = [
      dir.Direction.up,
      dir.Direction.right,
      dir.Direction.down,
      dir.Direction.left
    ];

    // Tracking visited cells and paths
    final visited = List.generate(rows, (_) => List.filled(columns, false));
    final paths = List.generate(
        rows, (_) => List.generate(columns, (_) => <dir.Direction>[]));

    // Queue for BFS
    final queue = <(int, int)>[(startX, startY)];
    visited[startY][startX] = true;

    while (queue.isNotEmpty) {
      final (x, y) = queue.removeAt(0);

      // Reached target
      if (x == targetX && y == targetY) {
        return paths[y][x];
      }

      // Try all directions
      for (final direction in directions) {
        int newX = x, newY = y;
        switch (direction) {
          case dir.Direction.up:
            newY--;
            break;
          case dir.Direction.right:
            newX++;
            break;
          case dir.Direction.down:
            newY++;
            break;
          case dir.Direction.left:
            newX--;
            break;
        }

        // Check if new cell is safe and not visited
        if (_isSafeCell(newX, newY) && !visited[newY][newX]) {
          queue.add((newX, newY));
          visited[newY][newX] = true;

          // Copy previous path and add new direction
          paths[newY][newX] = List.from(paths[y][x]);
          paths[newY][newX].add(direction);
        }
      }
    }

    // No safe path found
    return [];
  }

  // Generate path to gold and back to start
  List<dir.Direction?> calculatePath() {
    var (goldX, goldY) = _findGoldLocation();

    // If no gold found, return empty path
    if (goldX == -1 || goldY == -1) return [];

    // Check if we need to kill the Wumpus first
    var wumpusLocation = _findWumpusLocation();
    if (wumpusLocation != null && agent.hasArrow) {
      var (wumpusX, wumpusY) = wumpusLocation;
      // Find path to Wumpus
      final pathToWumpus =
          _findShortestSafePath(agent.x, agent.y, wumpusX, wumpusY);
      if (pathToWumpus.isNotEmpty) {
        // Add shooting arrow action
        return [...pathToWumpus, null];
      }
    }

    // Find path to gold
    final pathToGold = _findShortestSafePath(agent.x, agent.y, goldX, goldY);

    // If no safe path to gold, return empty path
    if (pathToGold.isEmpty) return [];

    // Combine paths
    final completePath = [
      ...pathToGold,
      null, // Pick up gold
      ...(_findShortestSafePath(goldX, goldY, 0, 0)) // Return to start
    ];

    return completePath;
  }

  // Execute the AI solution with callbacks
  void solve({
    required void Function(dir.Direction?) onMove,
    required void Function() onComplete,
    required void Function(String) onMessage,
    int moveDelayMs = 500,
  }) {
    // Calculate the path
    List<dir.Direction?> path = calculatePath();

    // Check if path is empty
    if (path.isEmpty) {
      onMessage('No safe path found!');
      onComplete();
      return;
    }

    // Use a Timer to create a delay between moves
    Timer.periodic(Duration(milliseconds: moveDelayMs), (timer) {
      if (path.isEmpty) {
        timer.cancel();
        onComplete();
        onMessage('AI completed the mission!');
        return;
      }

      var nextMove = path.removeAt(0);

      if (nextMove == null) {
        // Check if we're at the Wumpus location
        var wumpusLocation = _findWumpusLocation();
        if (wumpusLocation != null &&
            agent.x == wumpusLocation.$1 &&
            agent.y == wumpusLocation.$2) {
          onMessage('Shooting arrow at Wumpus!');
          // The game controller will handle the actual shooting
        } else {
          onMessage('Gold picked up!');
        }
      } else {
        onMove(nextMove);
      }
    });
  }
}
