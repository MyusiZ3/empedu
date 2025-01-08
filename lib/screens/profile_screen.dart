import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userEmail = '';
  String _userName = '';
  String _profileImage = 'assets/default_avatar.png'; // Default image
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
    _loadProfileFromFirestore(); // Load profile from Firestore
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Get user information from Firebase Authentication
  void _getUserInfo() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
        _userName = user.displayName ?? _getUserNameFromEmail(user.email ?? '');
        _emailController.text = _userEmail;
        _userNameController.text = _userName;
      });
    }
  }

  /// Extract username from email
  String _getUserNameFromEmail(String? email) {
    if (email == null) return '';
    String userName = email.split('@')[0];
    return userName.length > 8 ? userName.substring(0, 8) + '...' : userName;
  }

  /// Load profile data from Firestore
  Future<void> _loadProfileFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data()!;
          setState(() {
            _userNameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _profileImage = data['profileimage'] ?? 'assets/default_avatar.png';
            _birthDate = data['birthdate'] != null
                ? (data['birthdate'] as Timestamp).toDate()
                : null; // Convert Firestore Timestamp to DateTime
            selectedGender = data['gender'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  /// Save profile data to Firestore
  Future<void> _saveProfileToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {
              'name': _userNameController.text.trim(),
              'email': _emailController.text.trim(),
              'profileimage': _profileImage,
              'birthdate':
                  _birthDate, // DateTime will be converted to Firestore Timestamp
              'gender': selectedGender,
            },
            SetOptions(
                merge:
                    true)); // Merge: update existing fields without overwriting others
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  /// Pick profile image from gallery
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = pickedFile.path;
      });
    }
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushReplacementNamed('/login');
                }
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
            /// Header with profile image
            Stack(
              clipBehavior: Clip.none,
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
                // Gambar Profil dan Ikon Kamera
                Positioned(
                  top: 140, // Atur jarak dari atas
                  left: MediaQuery.of(context).size.width / 2 -
                      60, // Atur posisi tengah
                  child: GestureDetector(
                    onTap: _pickProfileImage, // Fungsi untuk memilih gambar
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage.startsWith('assets/')
                                ? AssetImage(_profileImage)
                                : FileImage(File(_profileImage))
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        // Ikon Kamera
                        Positioned(
                          top: 0, // Ikon berada di bawah gambar
                          left: 0, // Ikon berada di kanan bawah
                          child: CircleAvatar(
                            radius: 18, // Ukuran lingkaran ikon kamera
                            backgroundColor:
                                const Color.fromARGB(255, 150, 186, 247),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18, // Ukuran ikon kamera
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

            SizedBox(height: 100),
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

            /// Editable fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildEditableField('Name', _userNameController),
                  SizedBox(height: 12),
                  _buildEmailField(),
                  SizedBox(height: 12),
                  _buildDatePickerField(context),
                  SizedBox(height: 12),
                  _buildGenderDropdown(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveProfileToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff898de8),
                      minimumSize: const Size(147, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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

  Widget _buildEmailField() {
    return _buildEditableField('Email', _emailController);
  }

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
                fontFamily: 'Poppins-Bold',
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
