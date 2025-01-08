import 'package:empedu/firebase_options.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/login/login.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/dashboard/dashboard.dart'; // Dashboard
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import screens kategori
import 'package:empedu/pages/categories/math_screen.dart';
import 'package:empedu/pages/categories/drawing_screen.dart';

// Import Secure Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Pastikan file ini sudah ada
  );

  // Periksa apakah pengguna sudah login
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? isLoggedIn = await secureStorage.read(key: 'isLoggedIn');

  runApp(MyApp(isLoggedIn: isLoggedIn == 'true'));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn
          ? '/dashboard'
          : '/login', // Tentukan rute awal berdasarkan status login
      routes: {
        '/login': (context) => Login(),
        '/dashboard': (context) => DashboardPage(),
        'MathScreen': (context) => const MathScreen(), // Cocok dengan Firebase
        'DrawingScreen': (context) => const DrawingScreen(),
      },
    );
  }
}
