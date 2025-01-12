// Package
import 'package:empedu/screens/splash_screen.dart'; // Splash Screen
import 'package:empedu/pages/login/login.dart'; // Login
import 'package:empedu/pages/dashboard/dashboard.dart'; // Dashboard
import 'package:flutter/material.dart';

// Categories
import 'package:empedu/pages/categories/math_screen.dart';
import 'package:empedu/pages/categories/drawing_screen.dart';
import 'package:empedu/pages/categories/reading_screen.dart';
import 'package:empedu/pages/calculator/calculator.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firestore
import 'package:empedu/firebase_options.dart'; // Firebase Options
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Inisialisasi Firebase dengan opsi default
  );

  // Migrasi untuk memastikan field 'uid' di semua dokumen 'users'
  await migrateUsersUid();

  runApp(const MyApp());
}

// ---------------------------------------------------
// FUNGSI MIGRASI UNTUK MEMASTIKAN FIELD 'UID' DI USERS
// ---------------------------------------------------
Future<void> migrateUsersUid() async {
  try {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final snapshot = await usersCollection.get();

    for (var doc in snapshot.docs) {
      if (!doc.data().containsKey('uid')) {
        // Jika tidak ada field 'uid', tambahkan dengan nilai documentId
        await usersCollection.doc(doc.id).update({'uid': doc.id});
      }
    }
    debugPrint("Migration completed: All users now have a 'uid' field.");
  } catch (e) {
    debugPrint("Error during migration: $e");
  }
}

// ---------------------------------------------------
// APLIKASI UTAMA
// ---------------------------------------------------
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
