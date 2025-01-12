import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({Key? key}) : super(key: key);

  @override
  State<ChatDashboard> createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _contacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadContacts();
  }

  void _checkUser() {
    if (_currentUser == null) {
      debugPrint('User not logged in');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      debugPrint('User is logged in with UID: ${_currentUser!.uid}');
    }
  }

  /// Load contacts from Firestore
  Future<void> _loadContacts() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _contacts = data != null && data.containsKey('contacts')
              ? List<String>.from(data['contacts'])
              : [];
          _isLoading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({'contacts': []});
        setState(() {
          _contacts = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Generate unique chat room ID
  String _generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  /// Filter contacts based on search query
  List<dynamic> _filterContacts() {
    if (_searchQuery.isEmpty) {
      return _contacts;
    }
    return _contacts
        .where((contact) => contact
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _filterContacts();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chat Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0d1b34),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _searchQuery = value;
              }),
              decoration: InputDecoration(
                hintText: 'Search Chat',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xff898de8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// Contacts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredContacts.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Add contact to start chatting.'
                              : 'No chat found.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contactEmail = filteredContacts[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/default_avatar.png'),
                              ),
                              title: Text(
                                contactEmail.split('@')[0],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff0d1b34),
                                ),
                              ),
                              subtitle: Text(
                                contactEmail,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                final chatRoomId = _generateChatRoomId(
                                    _currentUser?.email ?? '', contactEmail);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatRoomId: chatRoomId,
                                      receiverEmail: contactEmail,
                                      receiverName: contactEmail.split('@')[0],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      /// Floating Action Button for Adding Contact
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  'Add Contact',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter email to add',
                    labelStyle: GoogleFonts.poppins(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: GoogleFonts.poppins()),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff898de8), // Warna tombol
                    ),
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        try {
                          // Cek apakah user ada di Firebase
                          final userQuery = await FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .get();

                          if (userQuery.docs.isNotEmpty) {
                            // Jika ditemukan, tambahkan email ke kontak
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_currentUser!.uid)
                                .update({
                              'contacts': FieldValue.arrayUnion([email]),
                            });

                            // Panggil ulang _loadContacts untuk memperbarui UI
                            await _loadContacts();

                            // Tampilkan pesan sukses
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email added',
                                  style: GoogleFonts.poppins(),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Jika tidak ditemukan, tampilkan pesan user not found
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'User not found',
                                  style: GoogleFonts.poppins(),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          // Tangani kesalahan
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'An error occurred: $e',
                                style: GoogleFonts.poppins(),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        // Hapus teks input setelah selesai
                        _emailController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Add',
                      style: GoogleFonts.poppins(
                        color: Colors.white, // Warna teks menjadi putih
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: const Color(0xff898de8),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
