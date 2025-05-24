import 'dart:async';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;

class WumpusAISolver {
  final Agent agent;
  final List<List<Cell>> grid;
  final int rows;
  final int columns;
  Timer? _moveTimer;
  bool _isDisposed = false;

  WumpusAISolver({
    required this.agent,
    required this.grid,
    required this.rows,
    required this.columns,
  });

  // Check if a cell is safe to move to based on sensory information
  bool _isSafeCell(int x, int y) {
    // Check bounds
    if (x < 0 || x >= columns || y < 0 || y >= rows) return false;

    // Check for hazards
    final cell = grid[y][x];
    if (cell.hasPit) return false;
    if (cell.hasWumpus && !cell.isWumpusDead) return false;

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

    // If we have an arrow and there's stench, we might be able to kill the Wumpus
    if (hasStench && agent.hasArrow) {
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

  // Find the shortest safe path using BFS
  List<dir.Direction> _findShortestSafePath(
    int startX,
    int startY,
    int targetX,
    int targetY,
  ) {
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
      rows,
      (_) => List.generate(columns, (_) => <dir.Direction>[]),
    );

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

        // Check if new cell is within bounds
        if (newX < 0 || newX >= columns || newY < 0 || newY >= rows) {
          continue;
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
        // Add shooting arrow action and then path to gold
        final pathToGold =
            _findShortestSafePath(wumpusX, wumpusY, goldX, goldY);
        if (pathToGold.isNotEmpty) {
          final returnPath = _findShortestSafePath(goldX, goldY, 0, 0);
          if (returnPath.isNotEmpty) {
            return [
              ...pathToWumpus,
              null, // Shoot arrow
              ...pathToGold,
              null, // Pick up gold
              ...returnPath, // Return to start
            ];
          }
        }
      }
    }

    // If we can't kill the Wumpus or don't need to, try direct path to gold
    final pathToGold = _findShortestSafePath(agent.x, agent.y, goldX, goldY);
    if (pathToGold.isEmpty) return [];

    final returnPath = _findShortestSafePath(goldX, goldY, 0, 0);
    if (returnPath.isEmpty) return [];

    // Combine paths
    return [
      ...pathToGold,
      null, // Pick up gold
      ...returnPath, // Return to start
    ];
  }

  // Execute the AI solution with callbacks
  void solve({
    required void Function(dir.Direction?) onMove,
    required void Function() onComplete,
    required void Function(String) onMessage,
    int moveDelayMs = 500,
  }) {
    // Reset disposal state
    _isDisposed = false;

    // Calculate the path
    List<dir.Direction?> path = calculatePath();

    // Check if path is empty
    if (path.isEmpty) {
      onMessage('No safe path found!');
      onComplete();
      return;
    }

    // Cancel any existing timer
    _moveTimer?.cancel();

    // Use a Timer to create a delay between moves
    _moveTimer = Timer.periodic(Duration(milliseconds: moveDelayMs), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (path.isEmpty) {
        timer.cancel();
        if (!_isDisposed) {
          onComplete();
          onMessage('AI completed the mission!');
        }
        return;
      }

      var nextMove = path.removeAt(0);

      if (nextMove == null) {
        // Check if we're at the Wumpus location
        var wumpusLocation = _findWumpusLocation();
        if (wumpusLocation != null &&
            agent.x == wumpusLocation.$1 &&
            agent.y == wumpusLocation.$2) {
          if (!_isDisposed) {
            onMessage('Shooting arrow at Wumpus!');
            onMove(null); // Signal to shoot arrow
          }
        } else {
          if (!_isDisposed) {
            onMessage('Gold picked up!');
            onMove(null); // Signal to pick up gold
          }
        }
      } else {
        if (!_isDisposed) {
          onMove(nextMove);
        }
      }
    });
  }

  // Add dispose method to clean up resources
  void dispose() {
    _isDisposed = true;
    _moveTimer?.cancel();
    _moveTimer = null;
  }
}
