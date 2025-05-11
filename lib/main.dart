import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'screens/game_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/initial_onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/grid_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // import the generated file

Future<void> main() async {
  try {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Configure platform channels with increased buffer size
    const platform = MethodChannel('flutter/platform');
    ServicesBinding.instance.defaultBinaryMessenger
        .setMessageHandler(platform.name, (message) async {
      return null;
    });

    // Initialize Firebase without waiting for Firestore test
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Run the app immediately after Firebase initialization
    runApp(const MyApp());

    // Test Firestore connection in the background
    _testFirestoreConnection();
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error initializing app: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  html.window.location.reload();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// Test Firestore connection in the background
Future<void> _testFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection('test')
        .doc('connection_test')
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'connected',
    });
    print('Firestore connection test successful');
  } catch (e) {
    print('Firestore connection test failed: $e');
  }
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
        '/grid_selection': (context) => const GridSelectionScreen(),
        '/welcome': (context) => const InitialOnboardingScreen(),
        '/tutorial': (context) => const OnboardingScreen(),
        '/rules': (context) => const RulesScreen(),
      },
    );
  }
}
