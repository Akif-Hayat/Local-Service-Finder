import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LocalServiceFinderApp());
}

class LocalServiceFinderApp extends StatelessWidget {
  const LocalServiceFinderApp({super.key});

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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
