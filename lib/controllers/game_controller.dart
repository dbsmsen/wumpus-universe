import 'dart:async';
import 'dart:math';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;
import '../models/grid.dart';

class GameController {
  late Agent agent;
  late Grid grid;
  bool isGameOver = false;
  bool autoMoveEnabled = false;
  String gameMessage = '';
  Timer? gameTimer;
  Duration gameDuration = Duration.zero;
  bool isGameRunning = false;
  final int rows;
  final int columns;

  GameController({required this.rows, required this.columns}) {
    initializeGame();
  }

  void initializeGame() {
    // Reset game state
    gameMessage = '';
    autoMoveEnabled = false;
    isGameOver = false;

    // Reset timer
    stopGameTimer();
    gameDuration = Duration.zero;

    // Initialize grid and agent
    grid = Grid(rows, columns);
    agent = Agent();

    // Randomize game elements
    grid.placePits();
    grid.placeWumpus();
    grid.placeGold();
    grid.placeAgent(agent);

    // Reset agent state
    agent.reset();

    // Start game timer
    startGameTimer();
  }

  void startGameTimer() {
    if (!isGameRunning) {
      isGameRunning = true;
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        gameDuration += const Duration(seconds: 1);
      });
    }
  }

  void stopGameTimer() {
    gameTimer?.cancel();
    isGameRunning = false;
  }

  void move(dir.Direction direction) {
    if (isGameOver || autoMoveEnabled) return;

    // Check if move is valid within grid boundaries
    int newX = agent.x;
    int newY = agent.y;

    switch (direction) {
      case dir.Direction.up:
        if (newY > 0) newY--;
        break;
      case dir.Direction.right:
        if (newX < columns - 1) newX++;
        break;
      case dir.Direction.down:
        if (newY < rows - 1) newY++;
        break;
      case dir.Direction.left:
        if (newX > 0) newX--;
        break;
    }

    // Only move if the new position is different
    if (newX != agent.x || newY != agent.y) {
      agent.move(direction);

      // Mark current cell as visited
      grid.cells[agent.y][agent.x].visited = true;

      // Check for hazards in current cell
      final currentCell = grid.cells[agent.y][agent.x];

      // Check for gold
      if (currentCell.hasGold) {
        agent.pickGold();
        gameMessage = 'You found the gold! Now return to the start!';
      }

      // Check for Wumpus
      if (currentCell.hasWumpus && !currentCell.isWumpusDead) {
        gameOverLose('The Wumpus got you!');
        return;
      }

      // Check for pit
      if (currentCell.hasPit) {
        gameOverLose('You fell into a pit!');
        return;
      }

      // Check win condition
      if (agent.hasGold && agent.x == 0 && agent.y == 0) {
        gameOverWin();
        return;
      }

      // Update sensory indicators for neighboring cells
      updateSensoryIndicators();
    }
  }

  void updateSensoryIndicators() {
    // Reset all sensory indicators first
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        grid.cells[y][x].stench = false;
        grid.cells[y][x].breeze = false;
      }
    }

    // Update sensory indicators based on hazards
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        final cell = grid.cells[y][x];

        if (cell.hasWumpus && !cell.isWumpusDead) {
          setStenchInNeighbors(x, y);
        }
        if (cell.hasPit) {
          setBreezeInNeighbors(x, y);
        }
      }
    }
  }

  void setStenchInNeighbors(int x, int y) {
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < columns && ny >= 0 && ny < rows) {
          grid.cells[ny][nx].stench = true;
        }
      }
    }
  }

  void setBreezeInNeighbors(int x, int y) {
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < columns && ny >= 0 && ny < rows) {
          grid.cells[ny][nx].breeze = true;
        }
      }
    }
  }

  void shootArrow() {
    if (isGameOver || !agent.hasArrow) return;

    if (agent.shootArrow()) {
      bool wumpusKilled = false;
      int checkX = agent.x;
      int checkY = agent.y;

      // Check cells in the direction of the arrow
      while (checkX >= 0 && checkX < columns && checkY >= 0 && checkY < rows) {
        final cell = grid.cells[checkY][checkX];

        if (cell.hasWumpus && !cell.isWumpusDead) {
          cell.isWumpusDead = true;
          wumpusKilled = true;
          agent.addPoints(500);
          gameMessage = 'You killed the Wumpus!';
          updateSensoryIndicators(); // Update stench indicators
          break;
        }

        // Move in the direction of the arrow
        switch (agent.direction) {
          case dir.Direction.up:
            checkY--;
            break;
          case dir.Direction.right:
            checkX++;
            break;
          case dir.Direction.down:
            checkY++;
            break;
          case dir.Direction.left:
            checkX--;
            break;
        }
      }

      if (!wumpusKilled) {
        gameMessage = 'Arrow missed!';
      }
    }
  }

  void gameOverWin() {
    stopGameTimer();
    gameMessage = 'Congratulations! You found the gold and returned safely!';
    isGameOver = true;
    agent.hasWon = true;
    agent.addPoints(500); // Win bonus
    revealAllPositions();
  }

  void gameOverLose(String reason) {
    stopGameTimer();
    agent.die();
    gameMessage = reason;
    isGameOver = true;
    agent.hasWon = false;
    revealAllPositions();
  }

  void revealAllPositions() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        grid.cells[y][x].isRevealed = true;
      }
    }
  }

  bool isNeighbor(int x, int y) {
    return (x == agent.x && (y == agent.y - 1 || y == agent.y + 1)) ||
        (y == agent.y && (x == agent.x - 1 || x == agent.x + 1));
  }

  void dispose() {
    stopGameTimer();
  }
}
