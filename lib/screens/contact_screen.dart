import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _searchController = TextEditingController(); // Untuk search bar
  bool _isAddingContact = false;
  String _searchQuery = '';

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
            "Are you sure you want to delete ${contact.name}?",
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
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteContact(contact.id!);
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

  /// Filter kontak berdasarkan pencarian
  List<Contact> _filterContacts() {
    if (_searchQuery.isEmpty) {
      return _contacts;
    }
    return _contacts
        .where((contact) =>
            contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            contact.phoneNumber
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
          'Contacts',
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
                hintText: 'Search Contacts',
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
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.contact_phone,
                            size: 80,
                            color: Color.fromARGB(255, 199, 201, 233)),
                        const SizedBox(height: 20),
                        Text(
                          'No contacts found.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xfff4837b)),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(contact),
                          ),
                          onTap: () {
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingContact = true;
          });
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(46),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
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
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff898de8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        '  Add Contact  ',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xff898de8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
