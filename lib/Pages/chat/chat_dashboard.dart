import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUser());
  }

  /// Cek apakah user sudah login
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

  /// Filter kontak berdasarkan pencarian
  List<String> _filterContacts(List<String> contacts) {
    if (_searchQuery.isEmpty) {
      return contacts;
    }
    return contacts
        .where((contact) =>
            contact.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Ambil nama pengguna dan last message berdasarkan email dari Firestore
  Future<Map<String, String>> _getUserInfo(String email) async {
    try {
      // Ambil nama pengguna
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      String userName =
          email.split('@')[0]; // Default ke email jika nama tidak ditemukan
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        userName = userData['name'] ?? userName;
      }

      // Ambil last message
      final chatRoomId = _generateChatRoomId(_currentUser!.email!, email);
      final chatRoomSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatRoomId)
          .get();

      String lastMessage = 'No messages yet.';
      if (chatRoomSnapshot.exists) {
        final data = chatRoomSnapshot.data();
        lastMessage = data?['lastMessage'] ?? lastMessage;
      }

      return {'name': userName, 'lastMessage': lastMessage};
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      return {'name': email.split('@')[0], 'lastMessage': 'No messages yet.'};
    }
  }

  /// Format timestamp menjadi waktu yang lebih ramah pengguna
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(date); // Format jam jika hari ini
    } else if (difference.inDays == 1) {
      return 'Yesterday'; // Format "Yesterday" jika kemarin
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE')
          .format(date); // Format hari (Senin, Selasa, dll.)
    } else {
      return DateFormat('MMM d, yyyy')
          .format(date); // Format lengkap jika lebih lama
    }
  }

  /// Tampilkan kontak
  Widget _buildContactList(List<String> contacts) {
    final filteredContacts = _filterContacts(contacts);

    if (filteredContacts.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No contacts yet. Add one!'
              : 'No contacts found.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contactEmail = filteredContacts[index];
        final chatRoomId =
            _generateChatRoomId(_currentUser!.email!, contactEmail);

        return GestureDetector(
          onLongPress: () => _showDeleteDialog(contactEmail),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .doc(chatRoomId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final chatData =
                  snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final lastMessage = chatData['lastMessage'] ?? 'No messages yet.';
              final lastTimestamp = chatData['lastTimestamp'] as Timestamp?;

              return FutureBuilder<Map<String, String>>(
                future: _getUserInfo(contactEmail),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final userInfo = userSnapshot.data!;
                  final userName = userInfo['name']!;
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff0d1b34),
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Text(
                        _formatTimestamp(lastTimestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: chatRoomId,
                              receiverEmail: contactEmail,
                              receiverName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Fungsi untuk menghapus kontak
  Future<void> _deleteContact(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'contacts': FieldValue.arrayRemove([email]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contact deleted successfully.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete contact.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Tampilkan dialog konfirmasi hapus kontak
  void _showDeleteDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Agar tidak bisa di-dismiss dengan klik di luar
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Delete Contact",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this contact?",
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "No",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _deleteContact(email); // Panggil fungsi delete kontak
              },
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Buat ID chat room unik berdasarkan dua email
  String _generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null || userData['contacts'] == null) {
            return Center(
              child: Text(
                'No contacts yet. Add one!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          final contacts =
              List<String>.from(userData['contacts'] as List<dynamic>);

          return Column(
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
                    hintText: 'Search Contact',
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xff898de8)),
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
                child: _buildContactList(contacts),
              ),
            ],
          );
        },
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
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Tutup dialog
                      Navigator.pop(context);
                      _emailController.clear(); // Bersihkan input
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff898de8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        try {
                          final userQuery = await FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .get();

                          if (userQuery.docs.isNotEmpty) {
                            // Jika pengguna ditemukan
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_currentUser!.uid)
                                .update({
                              'contacts': FieldValue.arrayUnion([email]),
                            });

                            // Tampilkan notifikasi sukses
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Contact added successfully.',
                                  style: GoogleFonts.poppins(),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Jika pengguna tidak ditemukan
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'User not found.',
                                  style: GoogleFonts.poppins(),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          // Jika terjadi error
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
                        _emailController.clear(); // Bersihkan input
                        Navigator.pop(context); // Tutup dialog
                      } else {
                        // Jika email kosong
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Email cannot be empty.',
                              style: GoogleFonts.poppins(),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Add',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
