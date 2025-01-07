import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ProfileScreen(),
    ContactScreen(),
  ];

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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Pagi  !',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF898DE8),
                          ),
                        ),
                        Text(
                          'Muhamad ...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF898DE8),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/Icon_Apps.png'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 204, 209, 255),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Pelajaran . .',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF898DE8),
                ),
              ),
              const SizedBox(height: 10),
              // Add Category Cards (similar to DashboardScreen)
              Expanded(
                child: ListView(
                  children: [
                    _buildCategoryCard(
                      context,
                      title: 'Menggambar',
                      lessons: '4 Pelajaran',
                      color: const Color(0xFF898DE8),
                      image: 'assets/Icon_Apps.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenggambarScreen()),
                        );
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Menghitung',
                      lessons: '3 Pelajaran',
                      color: const Color(0xFFF2C94C),
                      image: 'assets/Icon_Apps.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenggambarScreen()),
                        );
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Mewarnai',
                      lessons: '5 Pelajaran',
                      color: const Color.fromARGB(255, 242, 164, 190),
                      image: 'assets/Icon_Apps.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenggambarScreen()),
                        );
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Mini Kuis',
                      lessons: '5 Pelajaran',
                      color: const Color.fromARGB(255, 143, 244, 217),
                      image: 'assets/Icon_Apps.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenggambarScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required String lessons,
      required Color color,
      required String image,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  lessons,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contacts',
            style: TextStyle(
              fontFamily: 'Poppins-SemiBold',
              fontSize: 20,
              color: const Color(0xff6987f3),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.person, color: const Color(0xff7b88ff), size: 50),
        ],
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contact Book',
            style: TextStyle(
              fontFamily: 'Poppins-SemiBold',
              fontSize: 20,
              color: const Color(0xff6987f3),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.contacts, color: const Color(0xff7b88ff), size: 50),
        ],
      ),
    );
  }
}

// Screen Pelajaran
class MenggambarScreen extends StatelessWidget {
  const MenggambarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menggambar'),
      ),
      body: const Center(
        child: Text('Konten Pembelajaran Menggambar',
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
