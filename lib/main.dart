import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wumpus_universe/screens/game_screen.dart';

void main() {
  runApp(const WumpusWorldApp());
}

class WumpusWorldApp extends StatelessWidget {
  const WumpusWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wumpus World',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const GameScreen(),
    );
  }
}