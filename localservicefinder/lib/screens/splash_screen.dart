import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for Firebase Auth to restore the session
    // This ensures the user stays logged in after closing the app
    await Future.delayed(const Duration(seconds: 1));
    
    // Wait for auth state to be ready
    // Firebase Auth automatically persists sessions, but we need to wait for it to restore
    final auth = FirebaseAuth.instance;
    try {
      await auth.authStateChanges().first.timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      // If timeout, continue with current auth state
      debugPrint('Auth state check timeout, using current state: $e');
    }
    
    // Additional delay for splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    try {
      // Check if user is logged in (session should be restored by now)
      if (AuthService.isLoggedIn) {
        // Check user role and navigate accordingly
        try {
          final isAdmin = await AuthService.isAdmin();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => isAdmin
                    ? const AdminDashboardScreen()
                    : const HomeScreen(),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error checking admin status: $e');
          // Default to home screen if admin check fails
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback to login screen on any error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'asset/service.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Image load error: $error');
                      debugPrint('Stack trace: $stackTrace');
                      return const Icon(
                        Icons.build_circle,
                        color: Color(0xFF1976D2),
                        size: 60,
                      );
                    },
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        debugPrint('Image loaded synchronously');
                      }
                      return child;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Local Service Finder',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect with Local Professionals',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
