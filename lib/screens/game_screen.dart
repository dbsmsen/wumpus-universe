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
    grid = generateGrid();
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

    // Place gold at a minimum distance from agent
    int goldX = _random.nextInt(4);
    int goldY = _random.nextInt(6);
    int attempts = 0;
    const maxAttempts = 50; // Prevent infinite loops

    while ((!_isFarEnough(goldX, goldY, agent.x, agent.y) ||
            (goldX == agent.x && goldY == agent.y) ||
            (goldX == 0 && goldY == 0) ||
            (goldX == 3 && goldY == 0) ||
            (goldX == 0 && goldY == 5) ||
            (goldX == 3 && goldY == 5)) &&
        attempts < maxAttempts) {
      goldX = _random.nextInt(4);
      goldY = _random.nextInt(6);
      attempts++;
    }

    // If we couldn't find a suitable position after max attempts,
    // place it at the farthest corner from the agent
    if (attempts >= maxAttempts) {
      // Find the corner farthest from the agent
      List<Map<String, int>> corners = [
        {'x': 0, 'y': 0},
        {'x': 3, 'y': 0},
        {'x': 0, 'y': 5},
        {'x': 3, 'y': 5},
      ];

      Map<String, int> farthestCorner = corners.reduce((a, b) {
        int distA = (a['x']! - agent.x).abs() + (a['y']! - agent.y).abs();
        int distB = (b['x']! - agent.x).abs() + (b['y']! - agent.y).abs();
        return distA > distB ? a : b;
      });

      goldX = farthestCorner['x']!;
      goldY = farthestCorner['y']!;
    }

    grid[goldY][goldX].hasGold = true;
    grid[goldY][goldX].cellType = CellType.gold;

    // Place hazards
    _placeRandomObstacles();

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
        agent.x = _random.nextInt(4);
        agent.y = 0;
        break;
      case 1: // right edge
        agent.x = 3;
        agent.y = _random.nextInt(6);
        break;
      case 2: // bottom edge
        agent.x = _random.nextInt(4);
        agent.y = 5;
        break;
      case 3: // left edge
        agent.x = 0;
        agent.y = _random.nextInt(6);
        break;
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wumpus World',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Leaderboard & Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Tutorial'),
            leading: const Icon(Icons.school),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/tutorial');
            },
          ),
          ListTile(
            title: const Text('Rules & Instructions'),
            leading: const Icon(Icons.menu_book),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rules');
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Leaderboard'),
            leading: Icon(Icons.leaderboard),
          ),
          ..._leaderboard.map((score) => ListTile(
                title: Text('${score['name']} - Score: ${score['score']}'),
                subtitle:
                    Text('Moves: ${score['moves']}\nDate: ${score['date']}'),
              )),
          const Divider(),
          const ListTile(
            title: Text('Game Rules'),
            leading: Icon(Icons.info),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Find the gold and return to start'),
                Text('• Avoid pits and the Wumpus'),
                Text('• Use arrow to shoot Wumpus'),
                Text('• One arrow per game'),
                Text('• Watch for stench and breeze'),
              ],
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

  List<List<Cell>> generateGrid() {
    List<List<Cell>> newGrid = List.generate(
      6,
      (y) => List.generate(
        4,
        (x) => Cell(x: x, y: y),
      ),
    );
    return newGrid;
  }

  void _placeRandomObstacles() {
    // Place 3 pits
    for (int i = 0; i < 3; i++) {
      _placeObstacle(CellType.pit);
    }
    // Place 1 Wumpus
    _placeObstacle(CellType.wumpus);
  }

  void _placeObstacle(CellType type) {
    int x, y;
    do {
      x = _random.nextInt(4);
      y = _random.nextInt(6);
    } while ((x == agent.x && y == agent.y) || // Don't place on agent
        grid[y][x].cellType != CellType.empty || // Don't place on occupied cell
        (x == 0 && y == 0) || // Don't place in corners
        (x == 3 && y == 0) ||
        (x == 0 && y == 5) ||
        (x == 3 && y == 5));

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

        while (checkX >= 0 && checkX < 4 && checkY >= 0 && checkY < 6) {
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
      drawer: _buildDrawer(),
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
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Moves: ${agent.moves}',
                          style: const TextStyle(
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 2,
                              ),
                            ],
                          ),
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
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemCount: 24,
                      itemBuilder: (_, index) {
                        final x = index % 4;
                        final y = index ~/ 4;
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
                                  _addToLeaderboard('');
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
}
