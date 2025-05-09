import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/direction.dart' as dir;
import '../models/grid.dart';
import '../models/wumpus_ai_solver.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/about_dialog.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/rules_dialog.dart';
import '../widgets/theme_dialog.dart';
import '../widgets/tutorial_dialog.dart';
import '../widgets/sounds_dialog.dart';
import '../widgets/app_settings_dialog.dart';
import '../screens/leaderboard_screen.dart';
import '../widgets/game_actions.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;

  const GameScreen({super.key, required this.rows, required this.columns});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _gameController;
  Map<String, AnimationController> _cellAnimations = {};
  Timer? _gameTimer;
  Duration _gameDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _gameController =
        GameController(rows: widget.rows, columns: widget.columns);
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameDuration = Duration.zero;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _gameDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _gameController.dispose();
    _cellAnimations.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
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
    if (_gameController.agent.hasWon) {
      // Add to leaderboard logic here
    }
  }

  void _autoSolveWumpusWorld() {
    final aiSolver = WumpusAISolver(
      agent: _gameController.agent,
      grid: _gameController.grid.cells,
      rows: widget.rows,
      columns: widget.columns,
    );

    setState(() {
      _gameController.autoMoveEnabled = true;
      _gameController.gameMessage = 'AI solving the Wumpus World...';
    });

    aiSolver.solve(
      onMove: (move) {
        if (move != null) {
          setState(() {
            _gameController.agent.setDirection(move);
            _gameController.move(move);
          });
        }
      },
      onComplete: () {
        setState(() {
          _gameController.autoMoveEnabled = false;
          _gameController.gameMessage = 'AI solution complete!';
        });
      },
      onMessage: (message) {
        setState(() {
          _gameController.gameMessage = message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/grid_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: GameInfoPanel(
            agent: _gameController.agent,
            gameMessage: _gameController.gameMessage,
            gameDuration: _gameDuration,
            hasWon: _gameController.agent.hasWon,
            isGameOver: _gameController.isGameOver,
            autoMoveEnabled: _gameController.autoMoveEnabled,
            hasArrow: _gameController.agent.hasArrow,
            onShootArrow: () {
              setState(() {
                _gameController.shootArrow();
              });
            },
            onAutoSolve: _autoSolveWumpusWorld,
            onNewGame: () {
              setState(() {
                _gameController.initializeGame();
                _startGameTimer();
              });
            },
            onRestart: () {
              setState(() {
                _gameController.initializeGame();
                _startGameTimer();
              });
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Wumpus World Game'),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Game Duration: ${_formatDuration(_gameDuration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.score,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Score: ${_gameController.agent.score} | Moves: ${_gameController.agent.moves}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GameGrid(
                          grid: _gameController.grid,
                          agent: _gameController.agent,
                          isNeighbor: _gameController.isNeighbor,
                          cellAnimations: _cellAnimations,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GameActions(
                        isGameOver: _gameController.isGameOver,
                        autoMoveEnabled: _gameController.autoMoveEnabled,
                        hasArrow: _gameController.agent.hasArrow,
                        onShootArrow: () {
                          setState(() {
                            _gameController.shootArrow();
                          });
                        },
                        onAutoSolve: _autoSolveWumpusWorld,
                        onNewGame: () {
                          setState(() {
                            _gameController.initializeGame();
                            _startGameTimer();
                          });
                        },
                        onRestart: () {
                          setState(() {
                            _gameController.initializeGame();
                            _startGameTimer();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      GameControls(
                        isGameOver: _gameController.isGameOver,
                        autoMoveEnabled: _gameController.autoMoveEnabled,
                        onMove: (direction) {
                          setState(() {
                            _gameController.move(direction);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TutorialDialog(),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RulesDialog(),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GameAboutDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}
