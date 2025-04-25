import 'package:flutter/material.dart';
import 'dart:math';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Agent agent;
  late List<List<Cell>> grid;
  bool _autoMoveEnabled = true;
  bool _darkMode = false;
  final _random = Random();
  int moveCount = 0; // Track moves for scoring
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    agent = Agent();
    grid = generateGrid();
    _initializeGame();
  }

  List<List<Cell>> generateGrid() {
    return List.generate(4, (y) {
      return List.generate(4, (x) {
        return Cell(x: x, y: y);
      });
    });
  }

  void _initializeGame() {
    final corners = [[0, 0], [0, 3], [3, 0], [3, 3]];
    final start = corners[_random.nextInt(corners.length)];
    agent.x = start[0];
    agent.y = start[1];
    agent.isAlive = true;
    agent.hasGold = false;
    agent.hasWon = false;
    agent.score = 0;

    int goldX = _random.nextInt(4);
    int goldY = _random.nextInt(4);
    while (goldX == agent.x && goldY == agent.y) {
      goldX = _random.nextInt(4);
      goldY = _random.nextInt(4);
    }
    grid[goldY][goldX].hasGold = true;
    grid[goldY][goldX].cellType = CellType.gold; // Set CellType to gold

    _placeRandomObstacles();
  }

  void _placeRandomObstacles() {
    _placeObstacle(CellType.pit);
    _placeObstacle(CellType.wumpus);
  }

  void _placeObstacle(CellType type) {
    int x = _random.nextInt(4);
    int y = _random.nextInt(4);
    while (grid[y][x].hasGold || grid[y][x].hasPit || grid[y][x].hasWumpus || (x == agent.x && y == agent.y)) {
      x = _random.nextInt(4);
      y = _random.nextInt(4);
    }
    if (type == CellType.pit) {
      grid[y][x].hasPit = true;
      grid[y][x].cellType = CellType.pit; // Set CellType to pit
    } else if (type == CellType.wumpus) {
      grid[y][x].hasWumpus = true;
      grid[y][x].cellType = CellType.wumpus; // Set CellType to wumpus
    }
  }

  Future<void> _move(dir.Direction direction) async {
    if (!agent.isAlive || agent.hasWon) return;
    setState(() {
      agent.direction = direction;
      moveCount++;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    agent.move(direction);
    await _handleCurrentCell();
    setState(() {});
    if (_autoMoveEnabled && agent.isAlive && !agent.hasWon) _autoMove();
  }

  Future<void> _autoMove() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final queue = <List<int>>[];
    final visited = List.generate(4, (_) => List.filled(4, false));
    queue.add([agent.x, agent.y]);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final x = current[0], y = current[1];
      visited[y][x] = true;

      for (var next in agent.neighbors(x, y)) {
        final nx = next[0], ny = next[1];
        final cell = grid[ny][nx];
        if (!visited[ny][nx] && !cell.stench && !cell.breeze && !cell.hasPit && !cell.hasWumpus) {
          await _move(_dirTo(nx, ny));
          return;
        }
      }
    }
  }

  dir.Direction _dirTo(int x, int y) {
    if (x > agent.x) return dir.Direction.right;
    if (x < agent.x) return dir.Direction.left;
    if (y > agent.y) return dir.Direction.down;
    return dir.Direction.up;
  }

  Future<void> _handleCurrentCell() async {
    final cell = grid[agent.y][agent.x];
    if (cell.hasPit || cell.hasWumpus) {
      agent.isAlive = false;
      _gameOver = true;
    } else if (cell.hasGold) {
      agent.hasGold = true;
      agent.score += 1000;
    }
    if (agent.hasGold && agent.x == 0 && agent.y == 0) {
      agent.hasWon = true;
      agent.score += 500;
      _gameOver = true;
    }
    setState(() {});
  }

  Widget _buildCell(int x, int y) {
    final cell = grid[y][x];
    final isAgentHere = agent.x == x && agent.y == y;
    final List<Widget> content = [];

    if (_isNeighbor(x, y)) {
      if (cell.breeze) content.add(Image.asset('assets/images/breeze.png', width: 24));
      if (cell.stench) content.add(Image.asset('assets/images/stench.png', width: 24));
      if (cell.glitter) content.add(Image.asset('assets/images/glitter.png', width: 24));
      if (cell.hasPit) content.add(Image.asset('assets/images/pit.png', width: 24));
      if (cell.hasWumpus && !cell.isWumpusDead) content.add(Image.asset('assets/images/wumpus.png', width: 24));
      if (cell.isWumpusDead) content.add(Image.asset('assets/images/wumpus_dead.png', width: 24));
      if (cell.hasGold) content.add(Image.asset('assets/images/gold.png', width: 24));
      if (isAgentHere) content.add(Image.asset('assets/images/agent.png', width: 40)); // Increased size
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black54),
      ),
      margin: const EdgeInsets.all(2),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: content,
        ),
      ),
    );
  }

  bool _isNeighbor(int x, int y) {
    return (x == agent.x && (y == agent.y + 1 || y == agent.y - 1)) ||
        (y == agent.y && (x == agent.x + 1 || x == agent.x - 1));
  }

  IconData _directionIcon(dir.Direction d) {
    switch (d) {
      case dir.Direction.up:
        return Icons.arrow_upward;
      case dir.Direction.down:
        return Icons.arrow_downward;
      case dir.Direction.left:
        return Icons.arrow_back;
      case dir.Direction.right:
        return Icons.arrow_forward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wumpus World')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Points: ${agent.score}\nMoves: $moveCount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: 16,
              itemBuilder: (_, index) {
                final x = index % 4;
                final y = index ~/ 4;
                return _buildCell(x, y);
              },
            ),
          ),
          if (agent.hasWon)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '🎉 You found the gold and returned safely! 🎉',
                style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
          else if (!agent.isAlive)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '💀 Game Over. You died. 💀',
                style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dir.Direction.values.map((d) {
              return IconButton(
                icon: Icon(_directionIcon(d), size: 32),
                onPressed: () {
                  setState(() {
                    _autoMoveEnabled = false;
                  });
                  _move(d);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          if (_gameOver)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializeGame();
                  moveCount = 0;
                  _gameOver = false;
                });
              },
              child: const Text("Restart Game"),
            ),
        ],
      ),
    );
  }
}
