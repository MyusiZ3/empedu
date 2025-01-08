import 'package:empedu/Pages/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Add for image picking
import 'dart:io';
import 'package:intl/intl.dart';

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
      'color': Color(0xFFF2A4BE),
      'image': 'assets/Icon_Apps.png'
    },
    {
      'title': 'Mini Kuis',
      'lessons': '5 Pelajaran',
      'color': Color(0xFF8FF4D9),
      'image': 'assets/Icon_Apps.png'
    },
  ];

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

// Fungsi untuk menentukan salam berdasarkan waktu
  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 3 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 16) {
      return 'Good Afternoon!';
    } else {
      return 'Good Night !';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil email dari pengguna yang sedang login
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? ""; // Pastikan email ada
    String userName = _getUserNameFromEmail(email); // Ambil nama dari email

    // Filter kategori berdasarkan pencarian
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
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(), // Menampilkan salam berdasarkan waktu
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF898DE8),
                          ),
                        ),
                        Text(
                          userName, // Menampilkan username
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
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF898DE8),
                ),
              ),
              const SizedBox(height: 10),
              // Tampilkan pesan "Category Not Found" jika tidak ada kategori yang cocok
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
                // Add Category Cards (filtered by search query)
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MenggambarScreen()),
                          );
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
  }

  // Fungsi untuk memproses email dan mengambil nama pengguna
  String _getUserNameFromEmail(String email) {
    // Ambil bagian sebelum "@" dan batasi menjadi maksimal 8 karakter
    String userName = email.split('@')[0]; // Ambil sebelum '@'
    // Jika panjang nama > 8 karakter, tambahkan "..."
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

// Profile start
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userEmail = '';
  String _userName = '';
  String _profileImage = 'images/default_profile.jpg'; // Default image
  DateTime? _birthDate;
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female'];
  bool isEditing = true;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _userNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil email dan username dari Firebase Authentication
  void _getUserInfo() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
        _userName = user.displayName ?? _getUserNameFromEmail(user.email ?? '');
        _emailController.text = _userEmail; // Mengisi controller email
        _userNameController.text = _userName; // Mengisi controller username
      });
    }
  }

  // Mengambil nama pengguna dari email
  String _getUserNameFromEmail(String? email) {
    if (email == null) return '';
    String userName = email.split('@')[0]; // mengambil bagian sebelum '@'
    return userName.length > 8 ? userName.substring(0, 5) + '...' : userName;
  }

  // Fungsi untuk memilih gambar profil
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = pickedFile.path;
      });
    }
  }

  // Fungsi untuk mengupdate email di Firebase
  Future<void> _updateEmail(String email) async {
    try {
      if (email.endsWith('@gmail.com')) {
        User? user = FirebaseAuth.instance.currentUser;
        await user?.updateEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email berhasil diperbarui!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email harus menggunakan @gmail.com')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui email: $e')),
        );
      }
    }
  }

  // Fungsi untuk logout dengan konfirmasi
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you Sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Menutup dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => Login()), // Navigasi ke login.dart
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan foto profil dan tombol kamera
            Stack(
              clipBehavior: Clip.none, // Agar gambar profil tidak ter-clipping
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Color(0xff898de8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'PROFILE',
                      style: TextStyle(
                        fontFamily: 'Poppins-Bold',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 140, // Posisikan gambar sedikit lebih ke bawah
                  left: MediaQuery.of(context).size.width / 2 - 60, // Centered
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      clipBehavior:
                          Clip.none, // Agar icon kamera tidak ter-clipping
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width:
                                  4, // Tambahkan border putih untuk memperjelas gambar
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(File(_profileImage)),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        Positioned(
                          bottom: 10, // Atur posisi icon kamera
                          right: 5,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xff898de8),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height:
                    100), // Tambahkan jarak yang cukup agar gambar tidak menabrak konten
            // Informasi Pribadi
            Center(
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d1b34),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildEditableField('Nama', _userNameController),
                  SizedBox(height: 12),
                  _buildEmailField(),
                  SizedBox(height: 12),
                  _buildDatePickerField(context),
                  SizedBox(height: 12),
                  _buildGenderDropdown(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showLogoutDialog, // Tombol Logout
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff898de8),
                      minimumSize: const Size(147, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun field dengan gaya yang konsisten
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins-Medium',
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Field untuk email
  Widget _buildEmailField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        readOnly: !isEditing,
        onSubmitted: (value) {
          _updateEmail(value);
        },
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(fontFamily: 'Poppins-Medium', fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Date Picker
  Widget _buildDatePickerField(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _birthDate != null
                  ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                  : 'Date of Birth',
              style: TextStyle(
                fontFamily: 'Poppins-bold',
                fontSize: 14,
                color: Color(0xff677294),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today,
                color: const Color.fromARGB(255, 149, 149, 149)),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null && mounted) {
                setState(() {
                  _birthDate = pickedDate;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Dropdown untuk gender
  Widget _buildGenderDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: Text('Select Gender'),
          isExpanded: true,
          items: genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: isEditing
              ? (value) {
                  setState(() {
                    selectedGender = value;
                  });
                }
              : null,
        ),
      ),
    );
  }
}
// Profile end

// Kontak
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
