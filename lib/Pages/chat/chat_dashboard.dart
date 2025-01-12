import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({Key? key}) : super(key: key);

  @override
  State<ChatDashboard> createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _emailController = TextEditingController();
  List<dynamic> _contacts = [];
  String _searchQuery = '';
  bool _showAddContactField = false;

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
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({'contacts': []});
        setState(() {
          _contacts = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    }
  }

  /// Add contact
  Future<void> _addContact(String email) async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot =
          await usersCollection.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      final contactEmail = querySnapshot.docs.first['email'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'contacts': FieldValue.arrayUnion([contactEmail]),
      });

      _loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added')),
        );
      }
    } catch (e) {
      debugPrint('Error adding contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contact: $e')),
        );
      }
    }
  }

  /// Delete contact
  Future<void> _deleteContact(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'contacts': FieldValue.arrayRemove([email]),
      });

      _loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact removed')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove contact: $e')),
        );
      }
    }
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
        title: const Text('Chat Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: _currentUser != null ? Colors.green : Colors.red,
              radius: 10,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: _searchQuery),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'Search Contacts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _contacts.isEmpty
                ? const Center(
                    child: Text(
                      'No contacts found. Add a contact to start chatting.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contactEmail = filteredContacts[index];

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/default_avatar.png'),
                        ),
                        title: Text(contactEmail.split('@')[0]), // Display name
                        subtitle: Text(contactEmail), // Display email
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverEmail: contactEmail,
                                receiverName: contactEmail.split('@')[0],
                              ),
                            ),
                          );
                        },
                        onLongPress: () => _deleteContact(contactEmail),
                      );
                    },
                  ),
          ),
          if (_showAddContactField)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter email to add',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        _addContact(email);
                      }
                    },
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAddContactField = !_showAddContactField;
              });
            },
            child: Text(_showAddContactField ? 'Cancel' : 'Add Contact'),
          ),
        ],
      ),
    );
  }
}
