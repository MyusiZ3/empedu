import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:empedu/pages/chat/chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDashboardScreen extends StatefulWidget {
  const ChatDashboardScreen({super.key});

  @override
  ChatDashboardScreenState createState() => ChatDashboardScreenState();
}

class ChatDashboardScreenState extends State<ChatDashboardScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _contacts = []; // Ubah tipe menjadi dynamic
  bool _isAddContactVisible = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentReference userDocRef =
          _db.collection('users').doc(currentUser.uid);

      // Ambil dokumen pengguna
      DocumentSnapshot snapshot = await userDocRef.get();

      if (snapshot.exists) {
        // Cast data ke Map<String, dynamic>
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

        // Jika field "contacts" tidak ada, tambahkan secara otomatis
        if (!userData.containsKey('contacts')) {
          await userDocRef
              .update({'contacts': []}); // Tambahkan field contacts kosong
        }

        // Ambil daftar kontak dari field "contacts"
        List<dynamic> contacts = userData['contacts'] ?? [];
        setState(() {
          _contacts = List<Map<String, dynamic>>.from(contacts);
        });
      }
    }
  }

  Future<void> _addContact() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) return;

    // Cari UID berdasarkan email
    QuerySnapshot userSnapshot =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      String uid = userDoc.id;

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentReference userDocRef =
            _db.collection('users').doc(currentUser.uid);

        // Ambil dokumen pengguna
        DocumentSnapshot currentUserSnapshot = await userDocRef.get();
        Map<String, dynamic> userData =
            currentUserSnapshot.data() as Map<String, dynamic>;

        // Periksa apakah field "contacts" ada, jika tidak tambahkan
        if (!userData.containsKey('contacts')) {
          await userDocRef.update({'contacts': []});
        }

        // Tambahkan kontak baru ke field "contacts"
        await userDocRef.update({
          'contacts': FieldValue.arrayUnion([
            {'uid': uid, 'email': email}
          ])
        });

        _loadContacts(); // Perbarui daftar kontak
        _emailController.clear(); // Kosongkan input
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pengguna dengan email tersebut tidak ditemukan')),
      );
    }
  }

  Future<void> _deleteContact(String uid) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _db.collection('users').doc(currentUser.uid).update({
        'contacts': FieldValue.arrayRemove([
          {'uid': uid}
        ])
      });
      _loadContacts();
    }
  }

  void _startChat(String receiverUid, String receiverEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverUid: receiverUid,
          receiverEmail: receiverEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0d1b34),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_isAddContactVisible)
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Kontak',
                        prefixIcon: Icon(Icons.email_rounded),
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan email kontak',
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addContact,
                      child:
                          Text('Tambah Kontak', style: GoogleFonts.poppins()),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              Expanded(
                child: _contacts.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada kontak',
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            onTap: () =>
                                _startChat(contact['uid'], contact['email']),
                            title: Text(
                              contact['email'],
                              style: GoogleFonts.poppins(),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteContact(contact['uid']),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddContactVisible = !_isAddContactVisible;
          });
        },
        backgroundColor: const Color(0xff898de8),
        child: Icon(
          _isAddContactVisible ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
