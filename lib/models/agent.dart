import 'direction.dart';

class Agent {
  int x = 0;
  int y = 0;
  Direction direction = Direction.right;
  bool hasArrow = true;
  bool hasGold = false;
  bool isAlive = true;
  bool hasWon = false;
  int score = 0;  // Add a score field to track points

  // Move the agent based on the current direction
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

  // Set the direction for the agent
  void setDirection(Direction dir) {
    direction = dir;
  }

  // Reset agent's state to initial values
  void reset() {
    x = 0;
    y = 0;
    direction = Direction.right;
    hasArrow = true;
    hasGold = false;
    isAlive = true;
    hasWon = false;
    score = 0;  // Reset score to 0
  }

  // Get the neighboring cells around the agent
  List<List<int>> neighbors(int x, int y) {
    return [
      if (y > 0) [x, y - 1],
      if (y < 3) [x, y + 1],
      if (x > 0) [x - 1, y],
      if (x < 3) [x + 1, y],
    ];
  }

  // Add points to the score
  void addPoints(int points) {
    score += points;
  }

  // Check if the agent has won
  void checkWin() {
    if (hasGold && x == 0 && y == 0) {
      hasWon = true;
      addPoints(500);  // Add points for returning with gold
    }
  }
}
