import 'package:flutter/material.dart';
import 'package:empedu/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:empedu/screens/contact_screen.dart'; // Import ContactScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:empedu/screens/home_screen.dart'; // Import HomeScreen

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  /// List halaman untuk bottom navigation bar
  final List<Widget> _pages = [
    HomeScreen(), // Halaman HomeScreen
    ProfileScreen(), // Halaman ProfileScreen
    ContactScreen(), // Halaman ContactScreen
  ];

  /// Fungsi untuk menangani tap pada bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_rounded),
            label: 'Contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff7b88ff),
        onTap: _onItemTapped,
      ),
    );
  }
}
