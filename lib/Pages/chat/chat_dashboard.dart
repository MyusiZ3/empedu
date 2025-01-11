import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:empedu/Pages/chat/chat_page.dart';

class ChatDashboard extends StatefulWidget {
  @override
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _contacts = [];
  String _currentUserId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadContacts();
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    final userDoc =
        await _firestore.collection('users').doc(_currentUserId).get();

    if (userDoc.exists) {
      if (!userDoc.data()!.containsKey('contacts')) {
        // Jika field 'contacts' tidak ada, tambahkan secara otomatis
        await _firestore.collection('users').doc(_currentUserId).set({
          'contacts': [],
        }, SetOptions(merge: true)); // Merge agar tidak menimpa data lain
      }

      final contactEmails = List<String>.from(userDoc['contacts'] ?? []);
      if (contactEmails.isNotEmpty) {
        final contactDocs = await _firestore
            .collection('users')
            .where('email', whereIn: contactEmails)
            .get();

        setState(() {
          _contacts = contactDocs.docs
              .map((doc) => {'id': doc.id, ...doc.data()!})
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _contacts = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _contacts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addContact(String email) async {
    final contactDoc = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (contactDoc.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
      return;
    }

    final contactId = contactDoc.docs.first.id;

    final userDoc =
        await _firestore.collection('users').doc(_currentUserId).get();

    List<String> contacts =
        userDoc.exists && userDoc.data()!.containsKey('contacts')
            ? List<String>.from(userDoc['contacts'])
            : [];

    if (contacts.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact already exists')),
      );
      return;
    }

    contacts.add(email);

    await _firestore.collection('users').doc(_currentUserId).set({
      'contacts': contacts,
    }, SetOptions(merge: true)); // Merge agar tidak menimpa data lain

    _loadContacts();
  }

  Future<void> _deleteContact(String email) async {
    final userDoc =
        await _firestore.collection('users').doc(_currentUserId).get();

    if (userDoc.exists && userDoc['contacts'] != null) {
      List<String> contacts = List<String>.from(userDoc['contacts']);
      contacts.remove(email);

      await _firestore.collection('users').doc(_currentUserId).update({
        'contacts': contacts,
      });

      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text('Add Contact'),
                    content: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: 'Enter email'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _addContact(_emailController.text.trim());
                          _emailController.clear();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search contacts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      final searchQuery = _searchController.text.toLowerCase();
                      if (searchQuery.isNotEmpty &&
                          !contact['name']
                              .toLowerCase()
                              .contains(searchQuery) &&
                          !contact['email']
                              .toLowerCase()
                              .contains(searchQuery)) {
                        return Container();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: contact['profileimage'] != null &&
                                  contact['profileimage'].isNotEmpty
                              ? NetworkImage(contact['profileimage'])
                              : AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                        ),
                        title: Text(contact['name']),
                        subtitle: Text(contact['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteContact(contact['email']);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                contactId: contact['id'],
                                contactName: contact['name'],
                                contactEmail: contact['email'],
                                contactImage: contact['profileimage'] ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
