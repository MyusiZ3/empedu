import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // Menyimpan query pencarian
  List<Map<String, dynamic>> _categories = []; // Kategori dari Firestore

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Memuat kategori dari Firestore
  }

  /// Fungsi untuk mengonversi string warna ke Color
  Color parseColor(String colorString) {
    return Color(int.parse(colorString.substring(2), radix: 16) + 0xFF000000);
  }

  /// Fungsi untuk memuat kategori dari Firestore
  Future<void> _loadCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      setState(() {
        _categories = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "title": doc["title"],
            "lessons": doc["lessons"].toString(), // Pastikan diubah ke string
            "color": parseColor(doc["color"]), // Konversi warna dari string
            "image": doc["image"],
            "targetScreen": doc["targetScreen"],
          };
        }).toList();
      });
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  /// Fungsi untuk memperbarui pencarian
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Fungsi untuk mendapatkan greeting berdasarkan waktu
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

    if (user == null) {
      return Center(child: Text('No User Logged In'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No Profile Data Found'));
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;

        String userName = userData['name'] ?? 'User';
        String profileImage =
            userData['profileimage'] ?? 'assets/default_avatar.png';

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
                  /// Header Greeting dan Avatar
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
                          backgroundImage: profileImage.startsWith('assets/')
                              ? AssetImage(profileImage)
                              : FileImage(File(profileImage)) as ImageProvider,
                        ),
                      ],
                    ),
                  ),

                  /// Search Bar
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 204, 209, 255),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: _updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search Lessons...',
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

                  /// Kategori
                  const SizedBox(height: 20),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF898DE8),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// List Kategori atau Pesan Kosong
                  if (filteredCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                        child: Text(
                          'Category Not Found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
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
                            onTap: () {
                              Navigator.pushNamed(
                                  context, category['targetScreen']);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget untuk kartu kategori
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
                  "$lessons Lessons",
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
