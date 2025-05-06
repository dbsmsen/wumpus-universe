import 'package:flutter/material.dart';
import 'package:wumpus_universe/screens/game_screen.dart';
import 'package:wumpus_universe/screens/leaderboard_screen.dart';
import 'package:wumpus_universe/screens/settings_screen.dart';
import 'package:wumpus_universe/widgets/about_dialog.dart';
import 'package:wumpus_universe/widgets/logout_dialog.dart';
import 'package:wumpus_universe/widgets/rules_dialog.dart';
import 'package:wumpus_universe/widgets/section_card.dart';
import 'package:wumpus_universe/widgets/theme_dialog.dart';
import 'package:wumpus_universe/widgets/tutorial_dialog.dart';
import 'package:wumpus_universe/widgets/sounds_dialog.dart';
import 'package:wumpus_universe/widgets/app_settings_dialog.dart';

class GridSelectionScreen extends StatefulWidget {
  const GridSelectionScreen({super.key});

  @override
  State<GridSelectionScreen> createState() => _GridSelectionScreenState();
}

class _GridSelectionScreenState extends State<GridSelectionScreen> {
  // Predefined grid sizes
  final List<List<int>> predefinedGrids = [
    [4, 4], // Standard 4x4 grid
    [4, 6], // 4x6 grid
    [5, 5], // 5x5 grid
    [6, 6], // 6x6 grid
  ];

  // Default custom grid size
  List<int> customGridSize = [4, 4];

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          rows: rows,
          columns: columns,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left sidebar with game info
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Scrollable sections
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionCard(
                              title: 'Tutorial',
                              content:
                                  'Learn how to play the game and master the art of hunting the Wumpus.',
                              icon: Icons.school,
                              accentColor: Colors.blue,
                              onTap: () => _showTutorialDialog(context),
                            ),
                            SectionCard(
                              title: 'Sounds',
                              content:
                                  'Customize game audio and volume settings.',
                              icon: Icons.music_note,
                              accentColor: Colors.purple,
                              onTap: () => showSoundsDialog(context),
                            ),
                            SectionCard(
                              title: 'App Settings',
                              content:
                                  'Manage app preferences and appearance.',
                              icon: Icons.settings,
                              accentColor: Colors.teal,
                              onTap: () => showAppSettingsDialog(context),
                            ),
                            SectionCard(
                              title: 'Leaderboard',
                              content:
                                  'Check out the top players and their achievements.',
                              icon: Icons.leaderboard,
                              accentColor: Colors.amber,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LeaderboardScreen(),
                                ),
                              ),
                            ),
                            SectionCard(
                              title: 'Rules',
                              content:
                                  'Learn about the game rules and scoring system.',
                              icon: Icons.rule,
                              accentColor: Colors.green,
                              onTap: () => _showRulesDialog(context),
                            ),
                            SectionCard(
                              title: 'Theme',
                              content:
                                  'Customize the game appearance and colors.',
                              icon: Icons.palette,
                              accentColor: Colors.purple,
                              onTap: () => _showThemeDialog(context),
                            ),
                            SectionCard(
                              title: 'About',
                              content:
                                  'Learn more about Wumpus Universe and its creators.',
                              icon: Icons.info,
                              accentColor: Colors.teal,
                              onTap: () => _showAboutDialog(context),
                            ),
                            SectionCard(
                              title: 'Logout',
                              content:
                                  'Sign out and return to the login screen.',
                              icon: Icons.logout,
                              accentColor: Colors.red,
                              onTap: () => _showLogoutDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Choose Your Game Grid',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Text(
                              'Predefined Grids',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 40),
                            const Text(
                              'Custom Grid',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 40),
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
                              onPressed: () => _startGame(
                                customGridSize[0],
                                customGridSize[1],
                              ),
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
            ],
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
