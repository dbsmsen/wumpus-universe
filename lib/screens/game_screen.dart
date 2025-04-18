import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/agent.dart';
import '../models/cell.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int gridSize = 4;
  late List<List<Cell>> grid;
  Agent agent = Agent();
  Random random = Random();
  bool wumpusAlive = true;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) => Cell(x, y));
    });

    _placeRandomItem((cell) => cell.hasWumpus = true);
    _placeRandomItem((cell) => cell.hasGold = true);
    for (var row in grid) {
      for (var cell in row) {
        if (!(cell.x == 0 && cell.y == 0) && random.nextDouble() < 0.2) {
          cell.hasPit = true;
        }
      }
    }

    _addPercepts();
    grid[0][0].safe = true;
    grid[0][0].visited = true;
  }

  void _placeRandomItem(Function(Cell) assign) {
    int x, y;
    do {
      x = random.nextInt(4);
      y = random.nextInt(4);
    } while (x == 0 && y == 0);
    assign(grid[y][x]);
  }

  void _addPercepts() {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.hasWumpus) _addAdjacent(cell.x, cell.y, (adj) => adj.stench = true);
        if (cell.hasPit) _addAdjacent(cell.x, cell.y, (adj) => adj.breeze = true);
        if (cell.hasGold) cell.glitter = true;
      }
    }
  }

  void _addAdjacent(int x, int y, Function(Cell) update) {
    final offsets = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    for (var offset in offsets) {
      int nx = x + offset[0];
      int ny = y + offset[1];
      if (nx >= 0 && ny >= 0 && nx < 4 && ny < 4) {
        update(grid[ny][nx]);
      }
    }
  }

  Future<void> _move(Direction direction) async {
    agent.move(direction);
    await _handleCurrentCell();
    setState(() {});
    if (agent.isAlive && !agent.hasWon) _autoMove();
  }

  Future<void> _handleCurrentCell() async {
    Cell current = grid[agent.y][agent.x];
    current.visited = true;
    current.safe = true;

    if (current.hasPit || (current.hasWumpus && wumpusAlive)) {
      agent.isAlive = false;
      await player.play(AssetSource('sounds/death.mp3'));
    }

    if (current.hasGold) {
      agent.hasGold = true;
      current.hasGold = false;
      current.glitter = false;
      await player.play(AssetSource('sounds/gold.mp3'));
    }

    if (agent.hasGold && agent.x == 0 && agent.y == 0) {
      agent.hasWon = true;
    }
  }

  Future<void> _shootArrow() async {
    if (!agent.hasArrow) return;
    agent.hasArrow = false;

    int x = agent.x, y = agent.y;
    bool hit = false;
    switch (agent.direction) {
      case Direction.up:
        for (int i = y - 1; i >= 0; i--) if (grid[i][x].hasWumpus) { hit = true; break; }
        break;
      case Direction.down:
        for (int i = y + 1; i < 4; i++) if (grid[i][x].hasWumpus) { hit = true; break; }
        break;
      case Direction.left:
        for (int i = x - 1; i >= 0; i--) if (grid[y][i].hasWumpus) { hit = true; break; }
        break;
      case Direction.right:
        for (int i = x + 1; i < 4; i++) if (grid[y][i].hasWumpus) { hit = true; break; }
        break;
    }
    if (hit) {
      wumpusAlive = false;
      await player.play(AssetSource('sounds/scream.mp3'));
    }
    setState(() {});
  }

  void _resetGame() {
    agent.reset();
    wumpusAlive = true;
    _initializeGrid();
    setState(() {});
  }

  void _autoMove() async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (var next in agent.neighbors(agent.x, agent.y)) {
      final cell = grid[next[1]][next[0]];
      if (!cell.visited && !cell.stench && !cell.breeze) {
        await _move(_dirTo(next[0], next[1]));
        break;
      }
    }
  }

  Direction _dirTo(int x, int y) {
    if (y < agent.y) return Direction.up;
    if (y > agent.y) return Direction.down;
    if (x < agent.x) return Direction.left;
    return Direction.right;
  }

  Widget _buildCell(Cell cell) {
    bool isAgent = agent.x == cell.x && agent.y == cell.y;
    Color bgColor = cell.visited ? Colors.white : Colors.grey[300]!;
    if (!agent.isAlive && isAgent) bgColor = Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: bgColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isAgent) const Icon(Icons.person, color: Colors.blue),
          if (cell.glitter) const Icon(Icons.star, color: Colors.amber),
          if (cell.breeze && cell.visited)
            const Icon(Icons.air, color: Colors.cyan),
          if (cell.stench && cell.visited)
            const Icon(Icons.warning, color: Colors.green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wumpus World')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: 16,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (context, index) {
                int x = index % 4;
                int y = index ~/ 4;
                return _buildCell(grid[y][x]);
              },
            ),
          ),
          if (!agent.isAlive)
            const Text("You Died!", style: TextStyle(color: Colors.red, fontSize: 24)),
          if (agent.hasWon)
            const Text("You Escaped with the Gold!", style: TextStyle(color: Colors.green, fontSize: 24)),
          Wrap(
            spacing: 10,
            children: [
              for (var dir in Direction.values)
                ElevatedButton(
                  onPressed: agent.isAlive && !agent.hasWon ? () => _move(dir) : null,
                  child: Text(dir.name.toUpperCase()),
                ),
              ElevatedButton(
                onPressed: agent.isAlive && agent.hasArrow ? _shootArrow : null,
                child: const Text("SHOOT"),
              ),
              ElevatedButton(
                onPressed: _resetGame,
                child: const Text("RESTART"),
              )
            ],
          )
        ],
      ),
    );
  }
}
