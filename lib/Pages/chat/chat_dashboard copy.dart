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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkUser();
      await _syncContactsWithMessages();
    });
  }

  /// Sinkronisasi kontak dengan pesan
  Future<void> _syncContactsWithMessages() async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: _currentUser?.email)
        .get();

    for (var doc in messagesSnapshot.docs) {
      final participants = List<String>.from(doc['participants']);
      for (var participant in participants) {
        if (participant != _currentUser?.email) {
          await _autoAddContact(_currentUser!.email!, participant);
        }
      }
    }
  }

  /// Cek apakah user sudah login
  void _checkUser() {
    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// Tambahkan kontak secara otomatis
  Future<void> _autoAddContact(String senderEmail, String receiverEmail) async {
    try {
      // Tambahkan kontak ke pengirim
      final senderDoc =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      await senderDoc.set({
        'contacts': FieldValue.arrayUnion([receiverEmail]),
      }, SetOptions(merge: true));

      // Tambahkan kontak ke penerima
      final receiverQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: receiverEmail)
          .get();

      if (receiverQuery.docs.isNotEmpty) {
        final receiverDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(receiverQuery.docs.first.id);
        await receiverDoc.set({
          'contacts': FieldValue.arrayUnion([senderEmail]),
        }, SetOptions(merge: true));
      } else {
        // Jika dokumen penerima belum ada, buat dokumen baru
        final newReceiverDoc =
            FirebaseFirestore.instance.collection('users').doc();
        await newReceiverDoc.set({
          'email': receiverEmail,
          'contacts': [senderEmail],
        });
      }
    } catch (e) {
      debugPrint('Error auto-adding contact: $e');
    }
  }

  /// Format timestamp menjadi waktu yang lebih ramah pengguna
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(date); // Format waktu (jam dan menit)
    } else if (difference.inDays == 1) {
      return 'Yesterday'; // Jika kemarin
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date); // Jika dalam minggu ini
    } else {
      return DateFormat('MMM d, yyyy').format(date); // Format lengkap
    }
  }

  /// Tampilkan daftar kontak (diurutkan berdasarkan waktu terbaru)
  Widget _buildContactList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('participants', arrayContains: _currentUser?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatRooms = snapshot.data!.docs;

        if (chatRooms.isEmpty) {
          return Center(
            child: Text(
              'No contacts yet. Start a conversation!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          );
        }

        // Ambil semua kontak dan waktu pesan terakhir
        final List<Map<String, dynamic>> contacts = chatRooms.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final participants = List<String>.from(data['participants']);
          final otherUser = participants.firstWhere(
              (email) => email != _currentUser?.email,
              orElse: () => '');
          final lastTimestamp = data['lastTimestamp'] as Timestamp?;
          return {'email': otherUser, 'lastTimestamp': lastTimestamp};
        }).toList();

        // Urutkan berdasarkan waktu terbaru
        contacts.sort((a, b) {
          final timeA = a['lastTimestamp']?.toDate() ?? DateTime(1970);
          final timeB = b['lastTimestamp']?.toDate() ?? DateTime(1970);
          return timeB.compareTo(timeA);
        });

        // Filter berdasarkan pencarian
        final filteredContacts = contacts.where((contact) {
          return contact['email']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            final email = contact['email'];
            final lastTimestamp = contact['lastTimestamp'];

            return FutureBuilder<Map<String, String>>(
              future: _getUserInfo(email),
              builder: (context, userInfoSnapshot) {
                if (!userInfoSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final userInfo = userInfoSnapshot.data!;
                final userName = userInfo['name']!;
                final chatRoomId =
                    _generateChatRoomId(_currentUser!.email!, email);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatRoomId: chatRoomId,
                          receiverEmail: email,
                          receiverName: userName,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/default_avatar.png'),
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
                      'Last message at ${_formatTimestamp(lastTimestamp)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            );
          },
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

  /// Dialog untuk mengonfirmasi penghapusan kontak
  void _showDeleteDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                Navigator.of(context).pop();
                await _deleteContact(email);
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

  /// Fungsi untuk menambahkan kontak melalui input email
  Future<void> _addContact() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userQuery.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .update({
            'contacts': FieldValue.arrayUnion([email]),
          });

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
      _emailController.clear();
    } else {
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
  }

  /// Dialog untuk menambahkan kontak baru
  void _showAddContactDialog() {
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
                Navigator.pop(context);
                _emailController.clear();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _addContact();
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
  }

  /// Ambil nama pengguna berdasarkan email dari Firestore
  Future<Map<String, String>> _getUserInfo(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      return {'name': data['name'] ?? email.split('@')[0]};
    }
    return {'name': email.split('@')[0]};
  }

  /// Generate chat room ID
  String _generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0d1b34),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _searchQuery = value;
              }),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildContactList(),
          ),
        ],
      ),
    );
  }
}
