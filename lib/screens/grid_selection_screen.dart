import 'package:flutter/material.dart';
import 'package:wumpus_universe/screens/game_screen.dart';
import 'package:wumpus_universe/screens/leaderboard_screen.dart';
import 'package:wumpus_universe/screens/game_mechanics_screen.dart';
import 'package:wumpus_universe/screens/point_system_screen.dart';
import 'package:wumpus_universe/widgets/about_dialog.dart';
import 'package:wumpus_universe/widgets/logout_dialog.dart';
import 'package:wumpus_universe/widgets/theme_dialog.dart';
import 'package:wumpus_universe/widgets/tutorial_dialog.dart';
import 'package:wumpus_universe/widgets/sounds_dialog.dart';
import 'package:wumpus_universe/widgets/app_settings_dialog.dart';
import 'package:wumpus_universe/widgets/grid_selection_section.dart';
import 'package:wumpus_universe/widgets/game_settings_section.dart';
import 'package:wumpus_universe/models/game_mode.dart';
import 'package:wumpus_universe/models/difficulty_level.dart';
import 'package:wumpus_universe/services/audio_manager.dart';

class GridSelectionScreen extends StatefulWidget {
  const GridSelectionScreen({super.key});

  @override
  State<GridSelectionScreen> createState() => _GridSelectionScreenState();
}

class _GridSelectionScreenState extends State<GridSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final AudioManager _audioManager = AudioManager();

  // Predefined grid sizes
  final List<List<int>> predefinedGrids = [
    [4, 4], // Standard 4x4 grid
    [4, 6], // 4x6 grid
    [5, 5], // 5x5 grid
    [6, 6], // 6x6 grid
  ];

  // Default custom grid size
  List<int> customGridSize = [4, 4];
  bool isCustomGridSelected = false;
  bool isPredefinedGridSelected = false;
  List<int>? selectedGridSize;

  // Selected game mode and difficulty
  GameMode? selectedGameMode;
  DifficultyLevel? selectedDifficulty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
      _animationController.forward();
    });
  }

  Future<void> _initializeAudio() async {
    await _audioManager.initialize();
  }

  Future<void> _playClickSound() async {
    // Fire and forget sound effect
    _audioManager.playSoundEffect('sounds/click.wav');
  }

  Future<void> _playGridSelectionSound() async {
    // Fire and forget sound effect
    _audioManager.playSoundEffect('sounds/click.wav');
  }

  Future<void> _toggleMusic() async {
    if (_audioManager.isMusicPlaying) {
      await _audioManager.pauseBackgroundMusic();
    } else {
      await _audioManager.playBackgroundMusic();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioManager.dispose();
    super.dispose();
  }

  void _handleCustomGridSelected(int rows, int cols) {
    setState(() {
      customGridSize = [rows, cols];
      selectedGridSize = [rows, cols];
      isCustomGridSelected = true;
      isPredefinedGridSelected = false;
    });
  }

  void _handlePredefinedGridSelected(List<int> grid) {
    setState(() {
      selectedGridSize = grid;
      isPredefinedGridSelected = true;
      isCustomGridSelected = false;
    });
  }

  void _handleGameModeSelected(GameMode mode) {
    setState(() {
      selectedGameMode = mode;
    });
  }

  void _handleDifficultySelected(DifficultyLevel level) {
    setState(() {
      selectedDifficulty = level;
    });
  }

  // Navigate to game screen with selected grid size
  Future<void> _startGame(int rows, int columns) async {
    if (selectedGameMode == null || selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a game mode and difficulty level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Stop background music before navigation
    await AudioManager().enterGameScreen();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          rows: rows,
          columns: columns,
          gameMode: selectedGameMode!,
          difficultyLevel: selectedDifficulty!,
        ),
      ),
    );
  }

  final _drawerItems = const [
    {'icon': Icons.games, 'color': Colors.indigo, 'title': 'Game Mechanics', 'subtitle': 'Learn how to play'},
    {'icon': Icons.scoreboard, 'color': Colors.purple, 'title': 'Point System', 'subtitle': 'Scoring rules and penalties'},
    {'icon': Icons.school, 'color': Colors.blue, 'title': 'Tutorial', 'subtitle': 'Learn the basics'},
    {'icon': Icons.leaderboard, 'color': Colors.green, 'title': 'Leaderboard', 'subtitle': 'View top scores'},
    {'icon': Icons.palette, 'color': Colors.orange, 'title': 'Theme', 'subtitle': 'Customize appearance'},
    {'icon': Icons.volume_up, 'color': Colors.red, 'title': 'Sounds', 'subtitle': 'Audio settings'},
    {'icon': Icons.info, 'color': Colors.teal, 'title': 'About', 'subtitle': 'Game information'},
    {'icon': Icons.logout, 'color': Colors.grey, 'title': 'Logout', 'subtitle': 'Exit game'},
  ];

  Widget _buildDrawerItem(Map<String, dynamic> item, void Function() onTap) {
    return ListTile(
      leading: Icon(item['icon'] as IconData, color: item['color'] as Color),
      title: Text(item['title'] as String, style: const TextStyle(color: Colors.black)),
      subtitle: Text(item['subtitle'] as String, style: const TextStyle(color: Colors.black54)),
      tileColor: Colors.white,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            key: const PageStorageKey<String>('drawer_list'),
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wumpus Universe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Game Settings & Options',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ..._drawerItems.map((item) {
                final title = item['title'] as String;
                return _buildDrawerItem(
                  item,
                  () async {
                    await _playClickSound();
                    Navigator.pop(context);
                    switch (title) {
                      case 'Game Mechanics':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameMechanicsScreen(),
                          ),
                        );
                        break;
                      case 'Point System':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PointSystemScreen(),
                          ),
                        );
                        break;
                      case 'Tutorial':
                        _showTutorialDialog(context);
                        break;
                      case 'Leaderboard':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardScreen(),
                          ),
                        );
                        break;
                      case 'Theme':
                        _showThemeDialog(context);
                        break;
                      case 'Sounds':
                        _showSoundsDialog(context);
                        break;
                      case 'About':
                        _showAboutDialog(context);
                        break;
                      case 'Logout':
                        _showLogoutDialog(context);
                        break;
                    }
                  },
                );
              }).toList(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.indigo),
                title: const Text('About', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Game information', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard, color: Colors.amber),
                title: const Text('Leaderboard', style: TextStyle(color: Colors.black)),
                subtitle: const Text('View high scores', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.teal),
                title: const Text('App Settings', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Manage preferences', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  showAppSettingsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.purple),
                title: const Text('Sounds', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Audio settings', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  _showSoundsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.orange),
                title: const Text('Theme', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Customize appearance', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  _showThemeDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Rate & Review', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Rate on Google Play', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  // TODO: Add Google Play rating functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.indigo),
                title: const Text('About', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Game information', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              const Divider(color: Colors.black12),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Exit the game', style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () async {
                  await _playClickSound();
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 32,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _audioManager.isMusicPlaying ? Icons.volume_up : Icons.volume_off,
              color: _audioManager.isMusicPlaying ? Colors.white : Colors.red,
              size: 28,
            ),
            onPressed: _toggleMusic,
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Choose Your Game Style',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          GameSettingsSection(
                            selectedGameMode: selectedGameMode,
                            selectedDifficulty: selectedDifficulty,
                            onGameModeSelected: _handleGameModeSelected,
                            onDifficultySelected: _handleDifficultySelected,
                            onPlayClickSound: _playClickSound,
                          ),
                          const SizedBox(height: 32),
                          GridSelectionSection(
                            predefinedGrids: predefinedGrids,
                            customGridSize: customGridSize,
                            selectedGridSize: selectedGridSize,
                            isCustomGridSelected: isCustomGridSelected,
                            isPredefinedGridSelected: isPredefinedGridSelected,
                            onPredefinedGridSelected: _handlePredefinedGridSelected,
                            onCustomGridSelected: _handleCustomGridSelected,
                            onPlayClickSound: _playClickSound,
                            onPlayGridSelectionSound: _playGridSelectionSound,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () async {
                              await _playClickSound();
                              if (selectedGameMode == null ||
                                  selectedDifficulty == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select both a game mode and difficulty level'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedGridSize == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a grid size first'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              _startGame(
                                selectedGridSize![0],
                                selectedGridSize![1],
                              );
                            },
                            child: const Text(
                              'Enter with Selected Grid',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TutorialDialog(),
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

  void _showSoundsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SoundsDialog(
        audioManager: _audioManager,
        onVolumeChanged: (volume) async {
          await _audioManager.setBackgroundMusicVolume(volume);
          setState(() {});
        },
        isMusicPlaying: _audioManager.isMusicPlaying,
        onToggleMusic: _toggleMusic,
      ),
    );
  }
}
