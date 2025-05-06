import 'package:flutter/material.dart';
import 'dart:math';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;

  const GameScreen({super.key, required this.rows, required this.columns});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Agent agent;
  late List<List<Cell>> grid;
  bool _autoMoveEnabled = false;
  final _random = Random();
  bool _gameOver = false;
  String _gameMessage = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  Map<String, AnimationController> _cellAnimations = {};
  List<Map<String, dynamic>> _leaderboard = [];
  bool _showInstructions = true;
  int _currentInstruction = 0;
  final List<String> _instructions = [
    "Welcome to Wumpus World!",
    "Find the gold and return to your starting position.",
    "Watch out for pits and the Wumpus!",
    "Use the arrow button to shoot the Wumpus.",
    "You can only shoot once, so aim carefully!",
    "Good luck, adventurer!"
  ];

  @override
  void initState() {
    super.initState();
    agent = Agent();
    grid = generateGrid(rows: widget.rows, columns: widget.columns);
    _initializeGame();

    // Initialize main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cellAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isFarEnough(int x1, int y1, int x2, int y2) {
    // Calculate Manhattan distance between two points
    return (x1 - x2).abs() + (y1 - y2).abs() >=
        3; // Minimum distance of 3 cells
  }

  void _initializeGame() {
    // Place agent at random edge position
    _placeAgentAtRandomEdge();
    agent.reset();
    _gameOver = false;
    _gameMessage = '';

    // Adjust gold and obstacle placement based on grid size
    int goldX, goldY;
    int attempts = 0;
    const maxAttempts = 100;

    // Calculate the number of obstacles based on grid size
    int pitCount = (widget.rows * widget.columns ~/ 10).clamp(1, 5);
    int wumpusCount = 1;

    // Find a suitable position for gold
    do {
      goldX = _random.nextInt(widget.columns);
      goldY = _random.nextInt(widget.rows);
      attempts++;
    } while ((!_isFarEnough(goldX, goldY, agent.x, agent.y) ||
            (goldX == agent.x && goldY == agent.y) ||
            (goldX == 0 && goldY == 0)) &&
        attempts < maxAttempts);

    // If we couldn't find a suitable position, place at a random valid location
    if (attempts >= maxAttempts) {
      goldX = _random.nextInt(widget.columns);
      goldY = _random.nextInt(widget.rows);
    }

    grid[goldY][goldX].hasGold = true;
    grid[goldY][goldX].cellType = CellType.gold;

    // Place hazards with adjusted count
    for (int i = 0; i < pitCount; i++) {
      _placeObstacle(CellType.pit);
    }
    for (int i = 0; i < wumpusCount; i++) {
      _placeObstacle(CellType.wumpus);
    }

    // Set up percepts
    for (var row in grid) {
      for (var cell in row) {
        cell.setHazards(grid);
      }
    }
  }

  void _placeAgentAtRandomEdge() {
    int edge = _random.nextInt(4); // 0: top, 1: right, 2: bottom, 3: left
    switch (edge) {
      case 0: // top edge
        agent.x = _random.nextInt(widget.columns);
        agent.y = 0;
        break;
      case 1: // right edge
        agent.x = widget.columns - 1;
        agent.y = _random.nextInt(widget.rows);
        break;
      case 2: // bottom edge
        agent.x = _random.nextInt(widget.columns);
        agent.y = widget.rows - 1;
        break;
      case 3: // left edge
        agent.x = 0;
        agent.y = _random.nextInt(widget.rows);
        break;
    }
  }

  List<List<Cell>> generateGrid({required int rows, required int columns}) {
    List<List<Cell>> newGrid = List.generate(
      rows,
      (y) => List.generate(
        columns,
        (x) => Cell(x: x, y: y),
      ),
    );
    return newGrid;
  }

  void _placeObstacle(CellType type) {
    int x, y;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      x = _random.nextInt(widget.columns);
      y = _random.nextInt(widget.rows);
      attempts++;

      // Avoid placing on agent's position or gold
      if (x == agent.x && y == agent.y) continue;
      if (grid[y][x].hasGold) continue;

      // Ensure no duplicate obstacles
      if (grid[y][x].cellType == CellType.empty) {
        switch (type) {
          case CellType.pit:
            grid[y][x].hasPit = true;
            grid[y][x].cellType = CellType.pit;
            break;
          case CellType.wumpus:
            grid[y][x].hasWumpus = true;
            grid[y][x].cellType = CellType.wumpus;
            break;
          default:
            break;
        }
        break;
      }
    } while (attempts < maxAttempts);
  }

  Widget _buildCell(int x, int y) {
    final cell = grid[y][x];
    final isAgentHere = x == agent.x && y == agent.y;
    final isVisible = _isNeighbor(x, y) || isAgentHere;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isVisible ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isVisible) ...[
            // Only show stench and breeze in neighboring cells
            if (!isAgentHere) ...[
              if (cell.stench)
                _buildAnimatedImage('assets/images/stench.png', 'stench'),
              if (cell.breeze)
                _buildAnimatedImage('assets/images/breeze.png', 'breeze'),
            ],
            // Only show hazards and gold when agent is on the cell
            if (isAgentHere) ...[
              if (cell.hasPit)
                _buildAnimatedImage('assets/images/pit.png', 'pit'),
              if (cell.hasWumpus && !cell.isWumpusDead)
                _buildAnimatedImage('assets/images/wumpus.png', 'wumpus'),
              if (cell.hasWumpus && cell.isWumpusDead)
                _buildAnimatedImage(
                    'assets/images/wumpus_dead.png', 'wumpus_dead'),
              if (cell.hasGold)
                _buildAnimatedImage('assets/images/gold.png', 'gold'),
              if (cell.glitter)
                _buildAnimatedImage('assets/images/glitter.png', 'glitter'),
            ],
          ],
          if (isAgentHere) _buildAnimatedAgent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedImage(String imagePath, String key) {
    if (!_cellAnimations.containsKey(key)) {
      _cellAnimations[key] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);
    }

    return FadeTransition(
      opacity: _cellAnimations[key]!,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAnimatedAgent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Image.asset(
              'assets/images/agent.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  void _move(dir.Direction direction) {
    if (_gameOver) return;

    setState(() {
      agent.setDirection(direction);
      agent.move(direction);

      // Handle current cell effects
      _handleCurrentCell();
    });
  }

  void _handleCurrentCell() {
    final cell = grid[agent.y][agent.x];

    if (cell.hasPit) {
      _gameOver = true;
      _gameMessage = 'You fell into a pit!';
      agent.die();
    } else if (cell.hasWumpus && !cell.isWumpusDead) {
      _gameOver = true;
      _gameMessage = 'The Wumpus got you!';
      agent.die();
    } else if (cell.hasGold) {
      cell.hasGold = false;
      cell.cellType = CellType.empty;
      agent.pickGold();
      _gameMessage = 'You found the gold!';
    }

    // Check win condition
    if (agent.canClimbOut()) {
      _gameOver = true;
      agent.checkWin();
      _gameMessage = 'You won!';
      _showNameInputDialog();
    }
  }

  void _shootArrow() {
    if (_gameOver || !agent.hasArrow) return;

    setState(() {
      if (agent.shootArrow()) {
        // Check if Wumpus is in the line of fire
        int checkX = agent.x;
        int checkY = agent.y;

        while (checkX >= 0 &&
            checkX < widget.columns &&
            checkY >= 0 &&
            checkY < widget.rows) {
          final cell = grid[checkY][checkX];
          if (cell.hasWumpus && !cell.isWumpusDead) {
            cell.isWumpusDead = true;
            _gameMessage = 'You killed the Wumpus!';
            agent.addPoints(500);
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
      }
    });
  }

  bool _isNeighbor(int x, int y) {
    return (x == agent.x && (y == agent.y - 1 || y == agent.y + 1)) ||
        (y == agent.y && (x == agent.x - 1 || x == agent.x + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wumpus World'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showInstructions) _buildInstructionBanner(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Score: ${agent.score}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Moves: ${agent.moves}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_gameMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _gameMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: agent.hasWon ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.columns,
                      ),
                      itemCount: widget.rows * widget.columns,
                      itemBuilder: (_, index) {
                        final x = index % widget.columns;
                        final y = index ~/ widget.columns;
                        return _buildCell(x, y);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: dir.Direction.values.map((d) {
                            return IconButton(
                              icon: Icon(_directionIcon(d), size: 32),
                              onPressed: _gameOver ? null : () => _move(d),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed:
                              _gameOver || !agent.hasArrow ? null : _shootArrow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Shoot Arrow'),
                        ),
                        if (_gameOver)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _initializeGame();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('New Game'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey<int>(_currentInstruction),
        color: Colors.blue.shade200,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _instructions[_currentInstruction],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showInstructions = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _directionIcon(dir.Direction direction) {
    switch (direction) {
      case dir.Direction.up:
        return Icons.arrow_upward;
      case dir.Direction.right:
        return Icons.arrow_forward;
      case dir.Direction.down:
        return Icons.arrow_downward;
      case dir.Direction.left:
        return Icons.arrow_back;
    }
  }

  Future<void> _showNameInputDialog() async {
    String playerName = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You won the game!'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  playerName = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (playerName.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addToLeaderboard(playerName);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addToLeaderboard(String playerName) {
    if (agent.hasWon) {
      _leaderboard.add({
        'name': playerName,
        'score': agent.score,
        'moves': agent.moves,
        'date': DateTime.now().toString().split('.')[0],
      });
      _leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
      if (_leaderboard.length > 10) {
        _leaderboard = _leaderboard.sublist(0, 10);
      }
    }
  }
}
