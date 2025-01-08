import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact;
  final VoidCallback onUpdate;

  const EditContactScreen({
    Key? key,
    required this.contact,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.contact.name;
    _phoneController.text = widget.contact.phoneNumber;
  }

  Future<void> _updateContact() async {
    final name = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (name.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone number cannot be empty')),
      );
      return;
    }

    final updatedContact = Contact(
      id: widget.contact.id,
      name: name,
      phoneNumber: phoneNumber,
    );

    try {
      await DatabaseHelper.instance.updateContact(updatedContact);
      widget.onUpdate(); // Refresh data
      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateContact,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
