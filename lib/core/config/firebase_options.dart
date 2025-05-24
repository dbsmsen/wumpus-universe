// File: firebase_options.dart
// Firebase configuration for Wumpus Universe

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example of how to generate:
/// 1. Go to Firebase Console
/// 2. Select your project
/// 3. Go to Project Settings
/// 4. Add an app if not already done
/// 5. Download the configuration file
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can override this by passing handcrafted FirebaseOptions to '
          'Firebase.initializeApp',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOpnCdMLPkQwXD29VnW6CEeayS6vnkyYw',
    appId: '1:622050701723:web:04d35ef5c27b40bf73713e',
    messagingSenderId: '622050701723',
    projectId: 'wumpus-universe',
    authDomain: 'wumpus-universe.firebaseapp.com',
    storageBucket: 'wumpus-universe.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYc2S1nNxxGTnYA5TBnAM58saDb41qfB0',
    appId: '1:622050701723:android:af0611ded19e33b973713e',
    messagingSenderId: '622050701723',
    projectId: 'wumpus-universe',
    storageBucket: 'wumpus-universe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOpnCdMLPkQwXD29VnW6CEeayS6vnkyYw',
    appId: '1:622050701723:ios:04d35ef5c27b40bf73713e',
    messagingSenderId: '622050701723',
    projectId: 'wumpus-universe',
    storageBucket: 'wumpus-universe.firebasestorage.app',
    iosBundleId: 'com.example.wumpusUniverse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOpnCdMLPkQwXD29VnW6CEeayS6vnkyYw',
    appId: '1:622050701723:web:04d35ef5c27b40bf73713e',
    messagingSenderId: '622050701723',
    projectId: 'wumpus-universe',
    authDomain: 'wumpus-universe.firebaseapp.com',
    storageBucket: 'wumpus-universe.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCOpnCdMLPkQwXD29VnW6CEeayS6vnkyYw',
    appId: '1:622050701723:ios:04d35ef5c27b40bf73713e',
    messagingSenderId: '622050701723',
    projectId: 'wumpus-universe',
    storageBucket: 'wumpus-universe.firebasestorage.app',
    iosBundleId: 'com.example.wumpusUniverse.macos',
  );
}
