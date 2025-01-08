import 'package:empedu/firebase_options.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/login/login.dart'; // Sesuaikan dengan nama package
import 'package:empedu/pages/signup/signup.dart'; // Jika menggunakan halaman signup
import 'package:empedu/pages/dashboard/dashboard.dart'; // Jika menggunakan dashboard
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
        '/login': (context) => Login(), // Route untuk halaman login
        // '/signup': (context) => SignUp(), // Jika ada halaman signup
        '/dashboard': (context) =>
            DashboardPage(), // Route untuk halaman dashboard
      },
    );
  }
}
