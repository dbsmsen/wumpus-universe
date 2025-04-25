enum CellType {
  empty,
  pit,
  wumpus,
  gold,
}

class Cell {
  final int x, y;
  bool hasWumpus = false;
  bool hasPit = false;
  bool hasGold = false;
  bool visited = false;
  bool stench = false;
  bool breeze = false;
  bool glitter = false;
  bool safe = false;
  bool isWumpusDead = false;
  CellType cellType = CellType.empty;  // Add CellType property

  Cell({required this.x, required this.y});

  // Set hazards (stench, breeze, etc.) for this cell
  void setHazards(List<List<Cell>> grid) {
    if (hasPit) {
      _setBreezeInNeighbors(grid);
    }
    if (hasWumpus) {
      _setStenchInNeighbors(grid);
    }
  }

  // Helper function to set breeze in neighboring cells if there's a pit
  void _setBreezeInNeighbors(List<List<Cell>> grid) {
    // Loop over neighbors and set breeze flag
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < grid[0].length && ny >= 0 && ny < grid.length) {
          grid[ny][nx].breeze = true;
        }
      }
    }
  }

  // Helper function to set stench in neighboring cells if there's a Wumpus
  void _setStenchInNeighbors(List<List<Cell>> grid) {
    // Loop over neighbors and set stench flag
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < grid[0].length && ny >= 0 && ny < grid.length) {
          grid[ny][nx].stench = true;
        }
      }
    }
  }
}
