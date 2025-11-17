import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_init_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase is required - app will not work without it
  bool firebaseInitialized = false;
  String? initError;
  
  try {
    // Check if Firebase options are configured (not placeholder values)
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey == 'YOUR_WEB_API_KEY' || 
        options.projectId == 'YOUR_PROJECT_ID' ||
        (kIsWeb && options.appId.contains('YOUR_WEB_APP_ID'))) {
      throw Exception('Firebase is not properly configured. Please configure Firebase options. For web, you need to register your web app in Firebase Console and get the Web App ID.');
    }
    
    await Firebase.initializeApp(options: options);
    firebaseInitialized = true;
    
    // Initialize Firestore with default data if empty
    try {
      await FirestoreInitService.initializeFirestore();
    } catch (e) {
      debugPrint('Firestore initialization warning: $e');
      // Continue even if Firestore init fails
    }
    
    // Initialize admin users (set specific emails as admin)
    try {
      await AuthService.initializeAdminUsers();
    } catch (e) {
      debugPrint('Admin users initialization warning: $e');
      // Continue even if admin init fails
    }
  } catch (e) {
    // Firebase initialization failed - app cannot run without Firebase
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App requires Firebase to be properly configured.');
    initError = e.toString();
  }
  
  runApp(LocalServiceFinderApp(
    firebaseInitialized: firebaseInitialized,
    initError: initError,
  ));
}

class LocalServiceFinderApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String? initError;

  const LocalServiceFinderApp({
    super.key,
    required this.firebaseInitialized,
    this.initError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Service Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: firebaseInitialized
          ? const SplashScreen()
          : ErrorScreen(error: initError ?? 'Firebase initialization failed'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Please check your Firebase configuration and try again.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
