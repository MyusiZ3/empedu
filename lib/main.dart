import 'package:empedu/firebase_options.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/login/login.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/dashboard/dashboard.dart'; // Dashboard
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import screens kategori
import 'package:empedu/Pages/categories/math_screen.dart';
import 'package:empedu/pages/categories/drawing_screen.dart';

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
      initialRoute: '/login', // Tentukan route awal saat aplikasi dibuka
      routes: {
        '/login': (context) => Login(),
        '/dashboard': (context) => DashboardPage(),
        'MathScreen': (context) => const MathScreen(), // Cocok dengan Firebase
        'DrawingScreen': (context) => const DrawingScreen(),
      },
    );
  }
}
