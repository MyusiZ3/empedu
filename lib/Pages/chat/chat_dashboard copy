import 'package:flutter/material.dart';
import 'package:empedu/services/chat_service.dart'; // Import ChatService
import 'package:empedu/pages/chat/chat_screen.dart'; // Halaman untuk chat
import 'package:google_fonts/google_fonts.dart'; // Untuk penggunaan GoogleFonts

class ChatDashboardScreen extends StatefulWidget {
  @override
  _ChatDashboardScreenState createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ChatService _chatService = ChatService();
  List<String> _contacts = []; // Daftar email kontak yang terdaftar
  bool _isAddContactVisible =
      false; // Variabel untuk kontrol form tambah kontak

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Muat daftar kontak saat layar dibuka
  }

  // Memuat daftar kontak yang disimpan di Firestore
  _loadContacts() async {
    List<String> contacts = await _chatService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  // Menambahkan email ke daftar kontak
  _addContact() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty && !_contacts.contains(email)) {
      await _chatService.addContact(email); // Menambahkan email ke Firestore
      _loadContacts(); // Memperbarui daftar kontak
      _emailController.clear(); // Kosongkan input setelah menambah kontak
    }
  }

  // Menavigasi ke ChatScreen untuk mulai percakapan
  _startChat(String contactEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(receiverEmail: contactEmail),
      ),
    );
  }

  // Menampilkan dialog konfirmasi untuk menghapus kontak
  _confirmDeleteContact(String contactEmail) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus Kontak',
            style: GoogleFonts.poppins(),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus kontak $contactEmail?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteContact(contactEmail); // Menghapus kontak
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  // Menghapus kontak dari Firestore
  _deleteContact(String contactEmail) async {
    try {
      await _chatService
          .deleteContact(contactEmail); // Menghapus kontak di Firestore
      _loadContacts(); // Memperbarui daftar kontak
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kontak berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kontak')),
      );
    }
  }

  // Men-toggle visibility form tambah kontak
  _toggleAddContactForm() {
    setState(() {
      _isAddContactVisible = !_isAddContactVisible;
    });
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
              // Tampilkan form tambah kontak hanya jika _isAddContactVisible == true
              if (_isAddContactVisible)
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Contact Email',
                        prefixIcon: Icon(Icons.email_rounded),
                        border: OutlineInputBorder(),
                        hintText: 'Insert Contact Email',
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addContact, // Tombol untuk menambah kontak
                      child: Text('Add Contact', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        iconColor: const Color(0xff898de8), // Warna tombol
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: GoogleFonts.poppins(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              // Daftar kontak yang sudah ada
              Expanded(
                child: _contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Color(0xff898de8),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Tidak ada kontak',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contactEmail = _contacts[index];
                          return FutureBuilder<String>(
                            future: _chatService.getProfileImage(
                                contactEmail), // Ambil gambar profil
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListTile(
                                  onTap: () {
                                    _startChat(
                                        contactEmail); // Klik untuk mulai chat
                                  },
                                  title: Text(
                                    contactEmail,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                        'assets/default_avatar.png'), // Gambar default
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: const Color(0xFFF4837B),
                                    ),
                                    onPressed: () {
                                      _confirmDeleteContact(
                                          contactEmail); // Konfirmasi hapus kontak
                                    },
                                  ),
                                );
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return ListTile(
                                  onTap: () {
                                    _startChat(
                                        contactEmail); // Klik untuk mulai chat
                                  },
                                  title: Text(
                                    contactEmail,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                        'assets/default_avatar.png'), // Gambar default jika gagal
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: const Color(0xFFF4837B),
                                    ),
                                    onPressed: () {
                                      _confirmDeleteContact(
                                          contactEmail); // Konfirmasi hapus kontak
                                    },
                                  ),
                                );
                              } else {
                                String profileImageUrl = snapshot.data ??
                                    'assets/default_avatar.png';
                                return ListTile(
                                  onTap: () {
                                    _startChat(
                                        contactEmail); // Klik untuk mulai chat
                                  },
                                  title: Text(
                                    contactEmail,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                        profileImageUrl), // Menampilkan gambar profil dari URL
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: const Color(0xFFF4837B),
                                    ),
                                    onPressed: () {
                                      _confirmDeleteContact(
                                          contactEmail); // Konfirmasi hapus kontak
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddContactForm, // Toggle form tambah kontak
        child: Icon(_isAddContactVisible ? Icons.close : Icons.add,
            color: Colors.white),
        backgroundColor: const Color(0xff898de8),
      ),
    );
  }
}
