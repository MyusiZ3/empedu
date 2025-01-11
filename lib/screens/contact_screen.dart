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

  void _loadContacts() async {
    final contacts = await DatabaseHelper.instance.getContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
      });
    }
  }

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

  void _deleteContact(int id) async {
    try {
      await DatabaseHelper.instance.deleteContact(id);
      _loadContacts();
      _showSnackBar("Contact deleted successfully");
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 167, 170, 237),
      ),
    );
  }

  Future<void> _callContact(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      _showSnackBar("Unable to make a call to $phoneNumber");
    }
  }

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

  void _showDeleteConfirmationDialog(Contact contact) {
    showDialog(
      context: context,
      barrierDismissible: false, // Hanya bisa ditutup dengan tombol
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
            "Are you sure you want to delete ${contact.name}?",
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                "No",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteContact(contact.id!); // Hapus kontak
              },
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCall(String phoneNumber) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Make a Call",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Do you want to call $phoneNumber?",
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                "No",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _callContact(phoneNumber); // Lakukan panggilan
              },
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5cc35f),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Contacts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff0d1b34),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            if (_isAddingContact)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]*')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff898de8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '   Add Contact   ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _contacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.contact_phone,
                              size: 80,
                              color: Color.fromARGB(255, 199, 201, 233)),
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
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditContactScreen(
                                  contact: contact,
                                  onUpdate: _loadContacts,
                                ),
                              ),
                            ),
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
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.call,
                                      color: Color(0xff5cc35f)),
                                  onPressed: () =>
                                      _confirmCall(contact.phoneNumber),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat,
                                      color: Color(0xff898de8)),
                                  onPressed: () =>
                                      _chatWithContact(contact.phoneNumber),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Color(0xfff4837b)),
                                  onPressed: () =>
                                      _showDeleteConfirmationDialog(contact),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingContact = !_isAddingContact;
          });
        },
        backgroundColor: const Color(0xff898de8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
