import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wumpus_universe/controllers/game_controller.dart';
import 'package:wumpus_universe/models/direction.dart';
import 'package:wumpus_universe/models/game_mode.dart';
import 'package:wumpus_universe/models/difficulty_level.dart';
import 'package:wumpus_universe/services/audio_service.dart';
import 'package:wumpus_universe/widgets/game_controls.dart';
import 'package:wumpus_universe/widgets/game_grid.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;
  final GameMode gameMode;
  final DifficultyLevel difficultyLevel;

  const GameScreen({
    Key? key,
    required this.rows,
    required this.columns,
    required this.gameMode,
    required this.difficultyLevel,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum GameAction { newGame, restart, autoSolve }

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _gameController;
  late AudioService _audioService;
  Timer? _gameTimer;
  Duration _gameDuration = Duration.zero;
  final Map<String, AnimationController> _cellAnimations = {};
  bool _autoMoveEnabled = false;

  @override
  void initState() {
    super.initState();
    _gameController = GameController(
      rows: widget.rows,
      columns: widget.columns,
      gameMode: widget.gameMode,
      difficultyLevel: widget.difficultyLevel,
    );
    _audioService = AudioService();
    _startGameTimer();
    _audioService.playBackgroundMusic();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioService.stopBackgroundMusic();
    _gameController.dispose();
    _cellAnimations.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
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
        _audioService.playPitSound();
      } else if (_gameController.lastDeathCause == DeathCause.wumpus) {
        _audioService.playWumpusDeathSound();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.grey.shade900,
                title: const Text('Leave Game?', style: TextStyle(color: Colors.white)),
                content: const Text('Are you sure you want to leave the game? Your progress will be lost.',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back
                    },
                    child: const Text('Leave', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _audioService.isMusicPlaying
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: _audioService.isMusicPlaying ? Colors.white : Colors.red.shade400,
            ),
            onPressed: () {
              setState(() {
                if (_audioService.isMusicPlaying) {
                  _audioService.stopBackgroundMusic();
                } else {
                  _audioService.playBackgroundMusic();
                }
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),
              Color(0xFF311B92),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_gameController.isGameOver)
                                    Text(
                                      _gameController.agent.hasWon ? 'Congratulations!' : 'Game Over',
                                      style: TextStyle(
                                        color: _gameController.agent.hasWon
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Find the Gold!',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (_gameController.gameMessage.isNotEmpty)
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: Text(
                                          _gameController.gameMessage,
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score: ${_gameController.agent.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Time: ${_formatDuration(_gameDuration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
                          cellAnimations: _cellAnimations,
                          isNeighbor: _gameController.isNeighbor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_gameController.isGameOver)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _gameController = GameController(
                                      rows: widget.rows,
                                      columns: widget.columns,
                                      gameMode: widget.gameMode,
                                      difficultyLevel: widget.difficultyLevel,
                                    );
                                    _startGameTimer();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreenAccent.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'New Game',
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            if (!_gameController.isGameOver)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _gameController = GameController(
                                      rows: widget.rows,
                                      columns: widget.columns,
                                      gameMode: widget.gameMode,
                                      difficultyLevel: widget.difficultyLevel,
                                    );
                                    _startGameTimer();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Restart',
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: _gameController.isGameOver || _autoMoveEnabled
                                  ? null
                                  : () async {
                                      if (_autoMoveEnabled) return;
                                      setState(() {
                                        _autoMoveEnabled = true;
                                      });
                                      while (!_gameController.isGameOver &&
                                          _autoMoveEnabled) {
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        setState(() {
                                          _gameController.move(Direction.up);
                                        });
                                      }
                                      setState(() {
                                        _autoMoveEnabled = false;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'AI Solve',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _gameController.isGameOver || !_gameController.agent.hasArrow
                                  ? null
                                  : () {
                                      setState(() {
                                        _gameController.agent.shootArrow();
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Shoot Arrow',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GameControls(
                        onMove: (direction) {
                          setState(() {
                            _gameController.move(direction);
                          });
                        },
                        onShootArrow: () {
                          setState(() {
                            _gameController.agent.shootArrow();
                          });
                        },
                        onAutoSolve: () async {
                          if (_autoMoveEnabled) return;
                          setState(() {
                            _autoMoveEnabled = true;
                          });
                          while (!_gameController.isGameOver && _autoMoveEnabled) {
                            await Future.delayed(const Duration(milliseconds: 500));
                            setState(() {
                              _gameController.move(Direction.up);
                            });
                          }
                          setState(() {
                            _autoMoveEnabled = false;
                          });
                        },
                        isGameOver: _gameController.isGameOver,
                        autoMoveEnabled: _autoMoveEnabled,
                        hasArrow: _gameController.agent.hasArrow,
                        showActionButtons: false,
                      ),
                      const SizedBox(height: 12),
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
