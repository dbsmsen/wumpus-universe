import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show exit;
import 'screens/onboarding_screen.dart';
import 'screens/grid_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/config/firebase_options.dart'; // import the generated file
import 'package:wumpus_universe/screens/loading_screen.dart';

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

    // Initialize Firebase
    print('Initializing Firebase...');
    try {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();

      FirebaseApp app;
      try {
        // Try to get existing app first
        app = Firebase.app();
        print('Using existing Firebase app: ${app.name}');
      } catch (e) {
        // If no app exists, initialize a new one
        print('No existing Firebase app found, initializing new app...');
        app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase initialized successfully');
      }

      print('Firebase app name: ${app.name}');
      print('Firebase project ID: ${app.options.projectId}');
    } catch (e, stackTrace) {
      print('Error during Firebase initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }

    // Run the app immediately after Firebase initialization
    runApp(const MyApp());
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
                  // Exit the app
                  exit(0);
                },
                child: const Text('Exit App'),
              ),
            ],
          ),
        ),
      ),
    ));
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
      title: 'Wumpus Universe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B0000),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
      routes: {
        '/grid_selection': (context) => const GridSelectionScreen(),
        '/tutorial': (context) => const OnboardingScreen(),
      },
    );
  }
}
