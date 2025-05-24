import 'dart:async';
import 'package:flutter/material.dart';
import '../models/wumpus_ai_solver.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/game_actions.dart';
import '../models/game_mode.dart';
import '../models/difficulty_level.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;
  final GameMode gameMode;
  final DifficultyLevel difficultyLevel;

  const GameScreen({
    super.key,
    required this.rows,
    required this.columns,
    required this.gameMode,
    required this.difficultyLevel,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _gameController;
  final Map<String, AnimationController> _cellAnimations = {};
  Timer? _gameTimer;
  Duration _gameDuration = Duration.zero;
  WumpusAISolver? _aiSolver;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _gameController = GameController(
      rows: widget.rows,
      columns: widget.columns,
      gameMode: widget.gameMode,
      difficultyLevel: widget.difficultyLevel,
    );
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
    _aiSolver?.dispose();
    _cellAnimations.forEach((key, controller) {
      controller.dispose();
    });
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _playDeathSoundIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playDeathSoundIfNeeded();
  }

  void _playDeathSoundIfNeeded() {
    if (_gameController.isGameOver && !_gameController.agent.hasWon) {
      if (_gameController.lastDeathCause == DeathCause.pit) {
        _playPitSound();
      } else if (_gameController.lastDeathCause == DeathCause.wumpus) {
        _playWumpusDeathSound();
      }
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
    if (_gameController.agent.hasWon) {
      // Add to leaderboard logic here
    }
  }

  void _autoSolveWumpusWorld() {
    _aiSolver?.dispose();
    _aiSolver = WumpusAISolver(
      agent: _gameController.agent,
      grid: _gameController.grid.cells,
      rows: widget.rows,
      columns: widget.columns,
    );

    setState(() {
      _gameController.autoMoveEnabled = true;
      _gameController.gameMessage = 'AI solving the Wumpus World...';
    });

    _aiSolver!.solve(
      onMove: (move) {
        if (move != null) {
          setState(() {
            // First set the direction
            _gameController.agent.setDirection(move);
            // Then move in that direction
            _gameController.move(move);
            // Update the grid state
            _gameController.updateSensoryIndicators();
          });
        } else {
          // Handle special actions (shooting arrow or picking up gold)
          setState(() {
            if (_gameController.agent.hasArrow) {
              _gameController.shootArrow();
            } else if (_gameController
                .grid
                .cells[_gameController.agent.y][_gameController.agent.x]
                .hasGold) {
              _gameController.agent.pickGold();
            }
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

  Future<void> _playPitSound() async {
    await _audioPlayer.play(AssetSource('sounds/pit.wav'));
  }

  Future<void> _playWumpusDeathSound() async {
    await _audioPlayer.play(AssetSource('sounds/wumpus_death.wav'));
  }

  void _handleAgentDeath(bool killedByWumpus) {
    if (killedByWumpus) {
      _playWumpusDeathSound();
    } else {
      _playPitSound();
    }
    // Show game over dialog or navigate to a game over screen
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
        title: const Text(
          'The Wumpus Universe',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 32,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Show confirmation dialog before leaving
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text(
                      'You want to leave the current game?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context)
                            .pop(); // Return to grid selection screen
                      },
                      child: const Text('Leave'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
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
                            const Icon(
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
                            const Icon(
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
}
