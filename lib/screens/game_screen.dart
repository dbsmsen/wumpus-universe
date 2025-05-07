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

  @override
  void initState() {
    super.initState();
    _gameController =
        GameController(rows: widget.rows, columns: widget.columns);
  }

  @override
  void dispose() {
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
              // Game Duration Section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Game Duration: ${_formatDuration(_gameController.gameDuration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Left sidebar with game info
                    GameInfoPanel(
                      agent: _gameController.agent,
                      gameMessage: _gameController.gameMessage,
                      gameDuration: _gameController.gameDuration,
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
                        });
                      },
                      onRestart: () {
                        setState(() {
                          _gameController.initializeGame();
                        });
                      },
                    ),
                    // Main game grid
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: GameGrid(
                                grid: _gameController.grid,
                                agent: _gameController.agent,
                                isNeighbor: _gameController.isNeighbor,
                                cellAnimations: _cellAnimations,
                              ),
                            ),
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
}
