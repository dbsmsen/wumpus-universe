import 'direction.dart';

class Agent {
  int x = 0;
  int y = 0;
  Direction direction = Direction.right;
  bool hasArrow = true;
  bool hasGold = false;
  bool isAlive = true;
  bool hasWon = false;
  int score = 0;
  int moves = 0;
  bool canClimb = false;  // Can only climb out at starting position with gold

  // Constants for scoring
  static const int MOVE_COST = -1;
  static const int ARROW_COST = -10;
  static const int GOLD_REWARD = 1000;
  static const int DEATH_PENALTY = -1000;
  static const int WIN_BONUS = 500;

  // Move the agent based on the current direction
  void move(Direction dir) {
    if (!isAlive) return;
    
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
    
    moves++;
    addPoints(MOVE_COST);
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
    score = 0;
    moves = 0;
    canClimb = false;
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

  // Shoot arrow in the current direction
  bool shootArrow() {
    if (!hasArrow || !isAlive) return false;
    
    hasArrow = false;
    addPoints(ARROW_COST);
    return true;
  }

  // Pick up gold
  void pickGold() {
    if (!hasGold && isAlive) {
      hasGold = true;
      addPoints(GOLD_REWARD);
    }
  }

  // Die (fall into pit or eaten by Wumpus)
  void die() {
    if (isAlive) {
      isAlive = false;
      addPoints(DEATH_PENALTY);
    }
  }

  // Check if the agent can climb out
  bool canClimbOut() {
    return x == 0 && y == 0 && hasGold;
  }

  // Check if the agent has won
  void checkWin() {
    if (canClimbOut()) {
      hasWon = true;
      addPoints(WIN_BONUS);
    }
  }

  // Get the agent's current status
  String getStatus() {
    List<String> status = [];
    if (hasGold) status.add("Has Gold");
    if (hasArrow) status.add("Has Arrow");
    if (!isAlive) status.add("Dead");
    if (hasWon) status.add("Won");
    return status.join(", ");
  }
}