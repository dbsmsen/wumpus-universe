import 'package:flutter/material.dart';

class GameMode {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> settings;

  const GameMode({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.settings,
  });

  static const List<GameMode> modes = [
    GameMode(
      name: 'Classic',
      description:
          'Traditional Wumpus World gameplay with no time limit. Explore the cave and find the gold while avoiding the Wumpus.',
      icon: Icons.sports_esports,
      color: Colors.blue,
      settings: {
        'timeLimit': false,
        'wumpusCount': 1,
        'goldCount': 1,
        'pitCount': 3,
      },
    ),
    GameMode(
      name: 'Time Attack',
      description:
          'Race against the clock! Find the gold before time runs out. Each move costs precious seconds.',
      icon: Icons.timer,
      color: Colors.orange,
      settings: {
        'timeLimit': true,
        'timePerMove': 5,
        'wumpusCount': 1,
        'goldCount': 1,
        'pitCount': 3,
      },
    ),
    GameMode(
      name: 'Treasure Hunt',
      description: 'Multiple gold pieces to collect. Find them all to win!',
      icon: Icons.diamond,
      color: Colors.amber,
      settings: {
        'timeLimit': false,
        'wumpusCount': 1,
        'goldCount': 3,
        'pitCount': 3,
      },
    ),
    GameMode(
      name: 'Wumpus Hunter',
      description:
          'Hunt down multiple Wumpuses. Be careful, they\'re more aggressive!',
      icon: Icons.gps_fixed,
      color: Colors.purple,
      settings: {
        'timeLimit': false,
        'wumpusCount': 3,
        'goldCount': 1,
        'pitCount': 2,
        'wumpusAggressive': true,
      },
    ),
  ];
}
