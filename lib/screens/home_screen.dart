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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Menyimpan query pencarian
  List<Map<String, dynamic>> _categories = []; // Data kategori dari Firestore
  final FocusNode _searchFocusNode = FocusNode(); // Fokus untuk search bar

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
            "lessons": doc["lessons"].toString(), // Konversi ke string
            "color": parseColor(doc["color"]), // Konversi warna dari string
            "image": doc["image"],
            "targetScreen": doc["targetScreen"],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("Failed to load categories: $e");
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
      return const Center(child: Text('No User Logged In, Login First'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF898DE8),
                          ),
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                'User',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF898DE8),
                                ),
                              );
                            }

                            Map<String, dynamic> userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String userName = userData['name'] ?? 'User';

                            return Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF898DE8),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/default_avatar.png'),
                          );
                        }

                        Map<String, dynamic> userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        String profileImage = userData['profileimage'] ??
                            'assets/default_avatar.png';

                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImage.startsWith('assets/')
                              ? AssetImage(profileImage)
                              : FileImage(File(profileImage)) as ImageProvider,
                        );
                      },
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
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _updateSearchQuery,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  decoration: const InputDecoration(
                    hintText: 'Search Lessons...',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
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
              Expanded(
                child: _buildCategoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List kategori dengan pencarian
  Widget _buildCategoryList() {
    final filteredCategories = _categories
        .where((category) => category['title']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    if (filteredCategories.isEmpty) {
      return const Center(
        child: Text(
          'Category Not Found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return _buildCategoryCard(
          context,
          title: category['title'],
          lessons: category['lessons'],
          color: category['color'],
          image: category['image'],
          onTap: () {
            if (category['targetScreen'] != null &&
                category['targetScreen']!.isNotEmpty) {
              Navigator.pushNamed(context, category['targetScreen']);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Screen not found!'),
                ),
              );
            }
          },
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
              radius: 42,
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
