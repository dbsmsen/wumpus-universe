import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import '../widgets/auth_shared_widget.dart';
import '../widgets/floating_background.dart';
import 'register_screen.dart';
import 'package:flutter/services.dart';
import 'grid_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _showLoadingDialog(String message) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please wait while we process your request...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _login() async {
    try {
      print('Attempting email/password login...');
      if (_usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showError('Please enter both username and password');
        return;
      }

      await _showLoadingDialog('Signing In...');

      final email = "${_usernameController.text}@example.com";
      print('Attempting login with email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        print('Login successful for user: ${userCredential.user!.uid}');

        // Navigate immediately after successful authentication
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Close loading dialog
          _navigateToGridSelection();
        }

        // Update Firestore in the background
        print('Updating Firestore in background...');
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'username': _usernameController.text,
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).then((_) {
          print('User data successfully stored in Firestore');
        }).catchError((error) {
          print('Error storing user data in Firestore: $error');
          // Don't show error to user since this is a background operation
        });
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close loading dialog
        String errorMessage = 'Login failed. ';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage += 'No user found with this email.';
              break;
            case 'wrong-password':
              errorMessage += 'Wrong password provided.';
              break;
            case 'invalid-email':
              errorMessage += 'Invalid email address.';
              break;
            case 'user-disabled':
              errorMessage += 'This user account has been disabled.';
              break;
            default:
              errorMessage += e.message ?? 'Unknown error occurred.';
          }
        } else {
          errorMessage += e.toString();
        }
        _showError(errorMessage);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      print('Starting Google Sign In process...');

      if (!Firebase.apps.isNotEmpty) {
        print('Firebase not initialized!');
        _showError('Firebase not initialized. Please restart the app.');
        return;
      }

      // Show loading dialog immediately
      await _showLoadingDialog('Signing in with Google...');

      UserCredential userCredential;

      if (kIsWeb) {
        // Web platform
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile platforms (Android & iOS)
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close loading dialog
          }
          return; // User canceled the sign-in flow
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase authentication successful for user: ${user.uid}');

        // Navigate immediately after successful authentication
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Close loading dialog
          _navigateToGridSelection();
        }

        // Update Firestore in the background
        print('Updating Firestore in background...');
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        }, SetOptions(merge: true)).then((_) {
          print('User data successfully stored in Firestore');
        }).catchError((error) {
          print('Error storing user data in Firestore: $error');
          // Don't show error to user since this is a background operation
        });
      } else {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Close loading dialog
          print('Firebase authentication succeeded but user object is null');
          _showError('Failed to get user information after Google sign-in');
        }
      }
    } catch (e) {
      print('Google Sign In error: $e');
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close loading dialog
        String errorMessage = 'Google sign-in failed: ';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'account-exists-with-different-credential':
              errorMessage +=
                  'An account already exists with the same email address but different sign-in credentials.';
              break;
            case 'invalid-credential':
              errorMessage += 'The credential is invalid or has expired.';
              break;
            case 'operation-not-allowed':
              errorMessage += 'Google sign-in is not enabled.';
              break;
            case 'user-disabled':
              errorMessage += 'This user account has been disabled.';
              break;
            case 'user-not-found':
              errorMessage += 'No user found with this email.';
              break;
            case 'wrong-password':
              errorMessage += 'Wrong password provided.';
              break;
            case 'invalid-verification-code':
              errorMessage += 'The verification code is invalid.';
              break;
            case 'invalid-verification-id':
              errorMessage += 'The verification ID is invalid.';
              break;
            case 'popup-closed-by-user':
              errorMessage +=
                  'Sign-in popup was closed before completing the sign-in.';
              break;
            case 'popup-blocked':
              errorMessage += 'Sign-in popup was blocked by the browser.';
              break;
            default:
              errorMessage += e.message ?? 'Unknown error occurred.';
          }
        } else {
          errorMessage += e.toString();
        }
        _showError(errorMessage);
      }
    }
  }

  void _signInAsGuest() async {
    try {
      await _showLoadingDialog('Signing in as Guest...');

      await _auth.signInAnonymously();

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close loading dialog
        _navigateToGridSelection();
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Guest sign-in failed.');
      }
    }
  }

  void _navigateToGridSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const GridSelectionScreen(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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

    // Prevent screen capture
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    // Enable FLAG_SECURE to prevent screen capture
    SystemChannels.platform.invokeMethod('SystemNavigator.setSecureFlag', true);
  }

  @override
  void dispose() {
    // Disable FLAG_SECURE when leaving the screen
    SystemChannels.platform
        .invokeMethod('SystemNavigator.setSecureFlag', false);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B0000), // Deepest Brown
              Color(0xFF2C1810), // Very Deep Brown
              Color(0xFF3E2723), // Deep Brown
              Color(0xFF2C1810), // Very Deep Brown
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Add floating background
            const FloatingBackground(),
            // Background animated circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GlassmorphicCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'app_logo',
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurpleAccent[100]!
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.explore_rounded,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Wumpus Universe',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Explore the Mysterious World',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Username TextField
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.person_rounded,
                                  color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Password TextField
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock_rounded,
                                  color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Login Button
                          AnimatedButton(
                            onPressed: _login,
                            text: 'Login',
                            icon: Icons.login_rounded,
                            color: const Color(0xFFC4A50D), // Dark yellow color
                            textColor: Colors.white, // Blue text color
                          ),
                          const SizedBox(height: 24),
                          // Alternative Login Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                icon: const Icon(Icons.person_add_rounded,
                                    color: Colors.white),
                                label: const Text(
                                  'Register Here',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              TextButton.icon(
                                onPressed: _signInWithGoogle,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                icon: const FaIcon(
                                  FontAwesomeIcons.google,
                                  size: 20,
                                ),
                                label: const Text('Google Sign In'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Guest Sign-In
                          Center(
                            child: TextButton.icon(
                              onPressed: _signInAsGuest,
                              icon: const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Continue as s Guest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
    );
  }
}
