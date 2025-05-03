import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/initial_onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wumpus World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/welcome',
      routes: {
        '/game': (context) => const GameScreen(),
        '/welcome': (context) => const InitialOnboardingScreen(),
        '/tutorial': (context) => const OnboardingScreen(),
        '/rules': (context) => const RulesScreen(),
      },
    );
  }
}
