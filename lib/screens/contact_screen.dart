import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter
import 'package:url_launcher/url_launcher.dart'; // Untuk panggilan telepon dan WhatsApp
import '../models/contact.dart';
import '../database/database_helper.dart'; // Import DatabaseHelper
import 'edit_contact_screen.dart'; // Import Halaman Edit Contact

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> _contacts = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAddingContact = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Memuat kontak dari database
  void _loadContacts() async {
    final contacts = await DatabaseHelper.instance.getContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
      });
    }
  }

  // Menambah kontak baru
  void _addContact() async {
    final name = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (name.isEmpty || phoneNumber.isEmpty) {
      _showSnackBar("Name and phone number cannot be empty");
      return;
    }

    if (!RegExp(r'^(08|\+62)[0-9]{6,}$').hasMatch(phoneNumber)) {
      _showSnackBar("Phone number must start with +62 or 08 and be valid");
      return;
    }

    final newContact = Contact(name: name, phoneNumber: phoneNumber);
    try {
      await DatabaseHelper.instance.createContact(newContact);
      _loadContacts();
      _nameController.clear();
      _phoneController.clear();
      setState(() {
        _isAddingContact = false;
      });
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

  // Menghapus kontak berdasarkan ID
  void _deleteContact(int id) async {
    try {
      await DatabaseHelper.instance.deleteContact(id);
      _loadContacts();
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

  // Menampilkan SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  // Fungsi untuk panggilan telepon
  Future<void> _callContact(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      _showSnackBar("Unable to make a call to $phoneNumber");
    }
  }

  // Fungsi untuk chat menggunakan WhatsApp
  Future<void> _chatWithContact(String phoneNumber) async {
    if (phoneNumber.startsWith("08")) {
      phoneNumber = "+62${phoneNumber.substring(1)}";
    }

    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnackBar("Unable to open WhatsApp for $phoneNumber: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0d1b34),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form Tambah Kontak
              if (_isAddingContact) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9+]*'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text('Add Contact'),
                ),
                const SizedBox(height: 20),
              ],
              // Daftar Kontak
              Expanded(
                child: _contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.contact_phone,
                              size: 80,
                              color: Color(0xff898de8),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Contact list is empty',
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
                          final contact = _contacts[index];
                          return ListTile(
                            onTap: () {
                              // Navigasi ke halaman Edit Contact
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditContactScreen(
                                    contact: contact,
                                    onUpdate: _loadContacts,
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              contact.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              contact.phoneNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.call,
                                      color: Color.fromARGB(255, 92, 195, 95)),
                                  onPressed: () =>
                                      _callContact(contact.phoneNumber),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat,
                                      color: Color(0xff898de8)),
                                  onPressed: () =>
                                      _chatWithContact(contact.phoneNumber),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color:
                                          Color.fromARGB(255, 244, 131, 123)),
                                  onPressed: () => _deleteContact(contact.id!),
                                ),
                              ],
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
            _isAddingContact = !_isAddingContact;
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xff898de8),
      ),
    );
  }
}
