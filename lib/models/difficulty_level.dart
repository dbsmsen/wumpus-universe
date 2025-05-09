import 'package:flutter/material.dart';

class DifficultyLevel {
  final String name;
  final String description;
  final Color color;
  final Map<String, dynamic> settings;

  const DifficultyLevel({
    required this.name,
    required this.description,
    required this.color,
    required this.settings,
  });

  static const List<DifficultyLevel> levels = [
    DifficultyLevel(
      name: 'Easy',
      description: 'Perfect for beginners. Fewer hazards and more hints.',
      color: Colors.green,
      settings: {
        'wumpusCount': 1,
        'pitCount': 2,
        'hintFrequency': 0.8,
        'wumpusAggressiveness': 0.3,
      },
    ),
    DifficultyLevel(
      name: 'Medium',
      description: 'Balanced challenge. Standard number of hazards.',
      color: Colors.orange,
      settings: {
        'wumpusCount': 1,
        'pitCount': 3,
        'hintFrequency': 0.5,
        'wumpusAggressiveness': 0.5,
      },
    ),
    DifficultyLevel(
      name: 'Hard',
      description: 'For experienced players. More hazards and fewer hints.',
      color: Colors.red,
      settings: {
        'wumpusCount': 2,
        'pitCount': 4,
        'hintFrequency': 0.2,
        'wumpusAggressiveness': 0.7,
      },
    ),
    DifficultyLevel(
      name: 'Expert',
      description: 'Ultimate challenge. Maximum hazards and minimal hints.',
      color: Colors.purple,
      settings: {
        'wumpusCount': 3,
        'pitCount': 5,
        'hintFrequency': 0.1,
        'wumpusAggressiveness': 0.9,
      },
    ),
  ];
}
