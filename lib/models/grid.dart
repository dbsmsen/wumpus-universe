import 'dart:math';
import 'cell.dart';
import 'agent.dart';

class Grid {
  final int rows;
  final int columns;
  late List<List<Cell>> cells;

  Grid(this.rows, this.columns) {
    cells = List.generate(
      rows, 
      (y) => List.generate(
        columns, 
        (x) => Cell(x: x, y: y)
      )
    );
  }

  Cell operator [](int y) => cells[y] as Cell;

  void placePits() {
    final random = Random();
    int pitCount = (rows * columns * 0.2).round(); // 20% of cells have pits
    for (int i = 0; i < pitCount; i++) {
      int x, y;
      do {
        x = random.nextInt(columns);
        y = random.nextInt(rows);
      } while (cells[y][x].hasPit || (x == 0 && y == 0));
      cells[y][x].hasPit = true;
    }
  }

  void placeWumpus() {
    final random = Random();
    int x, y;
    do {
      x = random.nextInt(columns);
      y = random.nextInt(rows);
    } while ((x == 0 && y == 0) || cells[y][x].hasPit);
    cells[y][x].hasWumpus = true;
  }

  void placeGold() {
    final random = Random();
    int x, y;
    do {
      x = random.nextInt(columns);
      y = random.nextInt(rows);
    } while ((x == 0 && y == 0) || cells[y][x].hasPit || cells[y][x].hasWumpus);
    cells[y][x].hasGold = true;
  }

  void placeAgent(Agent agent) {
    agent.x = 0;
    agent.y = 0;
  }
}
