import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample leaderboard data (replace with actual data later)
  final List<Map<String, dynamic>> _leaderboardData = [
    {
      'rank': 1,
      'name': 'Master Explorer',
      'score': 2500,
      'gridSize': '6x6',
      'date': '2024-03-20'
    },
    {
      'rank': 2,
      'name': 'Cave Runner',
      'score': 2200,
      'gridSize': '5x5',
      'date': '2024-03-19'
    },
    {
      'rank': 3,
      'name': 'Gold Hunter',
      'score': 2000,
      'gridSize': '4x6',
      'date': '2024-03-18'
    },
    {
      'rank': 4,
      'name': 'Wumpus Slayer',
      'score': 1800,
      'gridSize': '4x4',
      'date': '2024-03-17'
    },
    {
      'rank': 5,
      'name': 'Cave Master',
      'score': 1600,
      'gridSize': '6x6',
      'date': '2024-03-16'
    },
    {
      'rank': 6,
      'name': 'Adventure Pro',
      'score': 1500,
      'gridSize': '5x5',
      'date': '2024-03-15'
    },
    {
      'rank': 7,
      'name': 'Explorer Elite',
      'score': 1400,
      'gridSize': '4x6',
      'date': '2024-03-14'
    },
    {
      'rank': 8,
      'name': 'Cave Crawler',
      'score': 1300,
      'gridSize': '4x4',
      'date': '2024-03-13'
    },
    {
      'rank': 9,
      'name': 'Gold Digger',
      'score': 1200,
      'gridSize': '6x6',
      'date': '2024-03-12'
    },
    {
      'rank': 10,
      'name': 'Wumpus Hunter',
      'score': 1100,
      'gridSize': '5x5',
      'date': '2024-03-11'
    },
  ];

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

  Widget _buildMedalIcon(int rank) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 24);
    } else if (rank == 2) {
      return const Icon(Icons.emoji_events, color: Colors.grey, size: 24);
    } else if (rank == 3) {
      return const Icon(Icons.emoji_events, color: Colors.brown, size: 24);
    }
    return Text(
      '#$rank',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_background.png'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              print('Error loading background image: $exception');
            },
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A1A)
                                    .withOpacity(0.95), // Very dark gray
                                Color(0xFF2D2D2D)
                                    .withOpacity(0.85), // Dark gray
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              // Header row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                        width: 40,
                                        child: Text('Rank',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        child: Text('Player',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: 100,
                                        child: Text('Score',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: 100,
                                        child: Text('Grid Size',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Leaderboard entries
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _leaderboardData.length,
                                  itemBuilder: (context, index) {
                                    final entry = _leaderboardData[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child:
                                                _buildMedalIcon(entry['rank']),
                                          ),
                                          Expanded(
                                            child: Text(
                                              entry['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              entry['score'].toString(),
                                              style: TextStyle(
                                                color: Colors.amber[300],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              entry['gridSize'],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
      ),
    );
  }
}
