// models/cell.dart
class Cell {
  final int x, y;
  bool hasWumpus = false;
  bool hasPit = false;
  bool hasGold = false;
  bool visited = false;
  bool stench = false;
  bool breeze = false;
  bool glitter = false;
  bool safe = false; // Used by AI

  Cell(this.x, this.y);
}
