import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/initial_onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // import the generated file


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
void addSampleData() async {
  try {
    await FirebaseFirestore.instance.collection('users').add({
      'name': 'John Doe',
      'email': 'johndoe@example.com',
    });
    print('Sample data added successfully');
  } catch (e) {
    print('Error adding sample data: $e');
  }
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
      // Start at login screen
      home: const LoginScreen(),
      routes: {
        '/game': (context) => const GameScreen(),
        '/welcome': (context) => const InitialOnboardingScreen(),
        '/tutorial': (context) => const OnboardingScreen(),
        '/rules': (context) => const RulesScreen(),
      },
    );
  }
}
