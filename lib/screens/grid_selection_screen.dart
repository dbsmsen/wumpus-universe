import 'package:flutter/material.dart';
import 'package:wumpus_universe/screens/game_screen.dart';
import 'package:wumpus_universe/screens/leaderboard_screen.dart';
import 'package:wumpus_universe/screens/settings_screen.dart';
import 'package:wumpus_universe/screens/game_mechanics_screen.dart';
import 'package:wumpus_universe/screens/point_system_screen.dart';
import 'package:wumpus_universe/widgets/about_dialog.dart';
import 'package:wumpus_universe/widgets/logout_dialog.dart';
import 'package:wumpus_universe/widgets/rules_dialog.dart';
import 'package:wumpus_universe/widgets/section_card.dart';
import 'package:wumpus_universe/widgets/theme_dialog.dart';
import 'package:wumpus_universe/widgets/tutorial_dialog.dart';
import 'package:wumpus_universe/widgets/sounds_dialog.dart';
import 'package:wumpus_universe/widgets/app_settings_dialog.dart';
import 'package:wumpus_universe/widgets/info_tooltip.dart';
import 'package:wumpus_universe/models/game_mode.dart';
import 'package:wumpus_universe/models/difficulty_level.dart';

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

  // Predefined grid sizes
  final List<List<int>> predefinedGrids = [
    [4, 4], // Standard 4x4 grid
    [4, 6], // 4x6 grid
    [5, 5], // 5x5 grid
    [6, 6], // 6x6 grid
  ];

  // Default custom grid size
  List<int> customGridSize = [4, 4];

  // Selected game mode and difficulty
  GameMode? selectedGameMode;
  DifficultyLevel? selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Show dialog for custom grid size input
  void _showCustomGridDialog() {
    final rowController =
        TextEditingController(text: customGridSize[0].toString());
    final colController =
        TextEditingController(text: customGridSize[1].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Grid Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rowController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rows',
                hintText: 'Enter number of rows (max: 10)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: colController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Columns',
                hintText: 'Enter number of columns (max: 10)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate input
              final rows = int.tryParse(rowController.text);
              final cols = int.tryParse(colController.text);

              if (rows != null && cols != null && rows > 0 && cols > 0) {
                if (rows > 10 || cols > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grid size cannot exceed 10x10'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() {
                  customGridSize = [rows, cols];
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid numbers greater than 0'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set Grid'),
          ),
        ],
      ),
    );
  }

  // Navigate to game screen with selected grid size
  void _startGame(int rows, int columns) {
    if (selectedGameMode == null || selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a game mode and difficulty level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
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
              ListTile(
                leading: const Icon(Icons.games, color: Colors.indigo),
                title: const Text('Game Mechanics',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('Learn how to play',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameMechanicsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.scoreboard, color: Colors.purple),
                title: const Text('Point System',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('Scoring rules and penalties',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PointSystemScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school, color: Colors.blue),
                title: const Text('Tutorial',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('Learn how to play',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showTutorialDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard, color: Colors.amber),
                title: const Text('Leaderboard',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('View high scores',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
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
                title: const Text('App Settings',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('Manage preferences',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  showAppSettingsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.purple),
                title:
                    const Text('Sounds', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Audio settings',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  showSoundsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.orange),
                title:
                    const Text('Theme', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Customize appearance',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showThemeDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Rate & Review',
                    style: TextStyle(color: Colors.black)),
                subtitle: const Text('Rate on Google Play',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add Google Play rating functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.indigo),
                title:
                    const Text('About', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Game information',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              const Divider(color: Colors.black12),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.black)),
                subtitle: const Text('Exit the game',
                    style: TextStyle(color: Colors.black54)),
                tileColor: Colors.white,
                onTap: () {
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
                          // Game Mode Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Center(
                                child: Text(
                                  'Game Mode',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: GameMode.modes.map((mode) {
                                  return InfoTooltip(
                                    message: mode.description,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          selectedGameMode = mode;
                                        });
                                      },
                                      icon: Icon(mode.icon),
                                      label: Text(mode.name),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedGameMode == mode
                                                ? mode.color
                                                : mode.color.withOpacity(0.5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Difficulty Level Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Center(
                                child: Text(
                                  'Difficulty Level',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: DifficultyLevel.levels.map((level) {
                                  return InfoTooltip(
                                    message: level.description,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedDifficulty = level;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedDifficulty == level
                                                ? level.color
                                                : level.color.withOpacity(0.5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(level.name),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Center(
                            child: Text(
                              'Predefined Grids',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: predefinedGrids.map((grid) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[700],
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () => _startGame(grid[0], grid[1]),
                                child: Text(
                                  '${grid[0]} x ${grid[1]}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          const Center(
                            child: Text(
                              'Custom Grid',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _showCustomGridDialog,
                            child: Text(
                              'Custom (${customGridSize[0]} x ${customGridSize[1]})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            onPressed: () {
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
                              _startGame(
                                customGridSize[0],
                                customGridSize[1],
                              );
                            },
                            child: const Text(
                              'Start Game with Selected Grid',
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
