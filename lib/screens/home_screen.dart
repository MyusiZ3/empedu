import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // Menyimpan query pencarian
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Menggambar',
      'lessons': '4 Pelajaran',
      'color': Color(0xFF898DE8),
      'image': 'assets/Icon_Apps.png'
    },
    {
      'title': 'Menghitung',
      'lessons': '3 Pelajaran',
      'color': Color(0xFFF2C94C),
      'image': 'assets/Icon_Apps.png'
    },
    {
      'title': 'Mewarnai',
      'lessons': '5 Pelajaran',
      'color': Color.fromARGB(255, 242, 164, 190),
      'image': 'assets/Icon_Apps.png'
    },
    {
      'title': 'Mini Kuis',
      'lessons': '5 Pelajaran',
      'color': Color.fromARGB(255, 143, 244, 217),
      'image': 'assets/Icon_Apps.png'
    },
  ];

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 3 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 16) {
      return 'Good Afternoon!';
    } else {
      return 'Good Night!';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? ""; // Pastikan email ada
    String userName = _getUserNameFromEmail(email); // Ambil nama dari email

    final filteredCategories = _categories
        .where((category) => category['title']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salam dan Foto Profil
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF898DE8),
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
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

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 204, 209, 255),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: _updateSearchQuery,
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

              // Kategori
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF898DE8),
                ),
              ),
              const SizedBox(height: 10),

              // Kategori Cards
              if (filteredCategories.isEmpty)
                Center(
                  child: Text(
                    'Category Not Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: filteredCategories.map((category) {
                      return _buildCategoryCard(
                        context,
                        title: category['title'],
                        lessons: category['lessons'],
                        color: category['color'],
                        image: category['image'],
                        onTap: () {},
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUserNameFromEmail(String email) {
    String userName = email.split('@')[0];
    return userName.length > 8 ? userName.substring(0, 8) + "..." : userName;
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
