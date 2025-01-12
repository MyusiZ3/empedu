import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileFromFirestore(); // Pindahkan ke PostFrameCallback
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

  String _getUserNameFromEmail(String? email) {
    if (email == null) return '';
    String userName = email.split('@')[0];
    return userName.length > 8 ? userName.substring(0, 8) + '...' : userName;
  }

  /// Load profile data from Firestore
  /// Load profile data from Firestore
  Future<void> _loadProfileFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Coba mengambil dokumen pengguna
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> data = snapshot.data()!;
          setState(() {
            _userNameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _profileImage = data['profileimage'] ?? 'assets/default_avatar.png';
            _birthDate = data['birthdate'] != null
                ? (data['birthdate'] as Timestamp).toDate()
                : null;
            selectedGender = data['gender'];
          });
        } else {
          // Jika dokumen tidak ditemukan, tampilkan pesan
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User profile not found.')),
            );
          });
        }
      } else {
        debugPrint('No user is signed in.');
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User is not signed in.')),
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      });
    }
  }

  Future<void> _saveProfileToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'name': _userNameController.text.trim(),
            'email': _emailController.text.trim(),
            'profileimage': _profileImage,
            'birthdate': _birthDate,
            'gender': selectedGender,
          },
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = pickedFile.path;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('Yes'),
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Color(0xff898de8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
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
                  top: 100,
                  left: MediaQuery.of(context).size.width / 2 - 65,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: _profileImage.startsWith('assets/')
                                ? AssetImage(_profileImage)
                                : FileImage(File(_profileImage))
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                const Color.fromARGB(255, 153, 158, 224),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
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
            const SizedBox(height: 90),
            const Center(
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildEditableField('Name', _userNameController),
                  const SizedBox(height: 12),
                  _buildEditableField('Email', _emailController),
                  const SizedBox(height: 12),
                  _buildDatePickerField(context),
                  const SizedBox(height: 12),
                  _buildGenderDropdown(),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _showLogoutDialog,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 3),
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
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
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
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: const Text('Select Gender'),
          isExpanded: true,
          items: genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),
      ),
    );
  }
}
