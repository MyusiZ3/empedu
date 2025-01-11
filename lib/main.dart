import 'package:empedu/firebase_options.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/login/login.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/dashboard/dashboard.dart'; // Dashboard
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import screens kategori
import 'package:empedu/pages/categories/math_screen.dart';
import 'package:empedu/pages/categories/drawing_screen.dart';
import 'package:empedu/pages/categories/reading_screen.dart';
import 'package:empedu/pages/calculator/calculator.dart';
import 'package:empedu/screens/splash_screen.dart'; // Splash Screen

// Import Secure Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Pastikan file ini sudah ada
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'empEDU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          const SplashScreen(), // Tetapkan SplashScreen sebagai halaman pertama
      routes: {
        '/login': (context) => Login(),
        '/dashboard': (context) => const DashboardPage(),
        'MathScreen': (context) => const MathScreen(),
        'DrawingScreen': (context) => const DrawingScreen(),
        'CalculatorPage': (context) => CalculatorPage(),
        'ReadingScreen': (context) => const ReadingScreen(),
      },
    );
  }
}
