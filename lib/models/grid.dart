import 'dart:math';
import 'cell.dart';
import 'agent.dart';

class Grid {
  final int rows;
  final int columns;
  late List<List<Cell>> cells;

  Grid(this.rows, this.columns) {
    cells = List.generate(
        rows, (y) => List.generate(columns, (x) => Cell(x: x, y: y)));
  }

  Cell operator [](int y) => cells[y] as Cell;

  void placePits({int count = -1}) {
    final random = Random();
    // Iterate through all cells except the first square
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        // Skip the first square (0,0)
        if (x == 0 && y == 0) continue;
        // 20% probability for each cell to have a pit
        if (random.nextDouble() < 0.2) {
          cells[y][x].hasPit = true;
        }
      }
    }
  }

  void placeWumpus({int count = 1}) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      int x, y;
      do {
        x = random.nextInt(columns);
        y = random.nextInt(rows);
      } while (
          (x == 0 && y == 0) || cells[y][x].hasPit || cells[y][x].hasWumpus);
      cells[y][x].hasWumpus = true;
    }
  }

  void placeGold({int count = 1}) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      int x, y;
      do {
        x = random.nextInt(columns);
        y = random.nextInt(rows);
      } while ((x == 0 && y == 0) ||
          cells[y][x].hasPit ||
          cells[y][x].hasWumpus ||
          cells[y][x].hasGold);
      cells[y][x].hasGold = true;
    }
  }

  void placeAgent(Agent agent) {
    agent.x = 0;
    agent.y = 0;
  }
}
