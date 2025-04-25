enum Direction { up, down, left, right }

class Agent {
  int x = 0;
  int y = 0;
  Direction direction = Direction.right;
  bool hasArrow = true;
  bool hasGold = false;
  bool isAlive = true;
  bool hasWon = false;

  void move(Direction dir) {
    direction = dir;
    switch (dir) {
      case Direction.up:
        if (y > 0) y--;
        break;
      case Direction.down:
        if (y < 3) y++;
        break;
      case Direction.left:
        if (x > 0) x--;
        break;
      case Direction.right:
        if (x < 3) x++;
        break;
    }
  }

  void setDirection(Direction dir) {
    direction = dir;
  }

  void reset() {
    x = 0;
    y = 0;
    direction = Direction.right;
    hasArrow = true;
    hasGold = false;
    isAlive = true;
    hasWon = false;
  }

  List<List<int>> neighbors(int x, int y) {
    return [
      if (y > 0) [x, y - 1],
      if (y < 3) [x, y + 1],
      if (x > 0) [x - 1, y],
      if (x < 3) [x + 1, y],
    ];
  }
}
