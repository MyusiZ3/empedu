import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String contactId;
  final String contactName;
  final String contactEmail;
  final String contactImage;

  const ChatPage({
    super.key,
    required this.contactId,
    required this.contactName,
    required this.contactEmail,
    required this.contactImage,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  /// Mendapatkan user ID dari FirebaseAuth
  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      debugPrint("Logged in user ID: $_currentUserId");
      debugPrint("Logged in user email: ${user.email}");
    } else {
      debugPrint("User is not logged in.");
    }
  }

  /// Mengirim pesan
  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final chatId = _getChatId(_currentUserId, widget.contactId);
    debugPrint("Chat ID: $chatId");

    final chatDoc = _firestore.collection('chats').doc(chatId);

    try {
      // Periksa apakah dokumen chat sudah ada
      final chatSnapshot = await chatDoc.get();
      debugPrint("Chat exists: ${chatSnapshot.exists}");

      if (!chatSnapshot.exists) {
        debugPrint("Creating new chat document...");
        // Buat dokumen baru dengan field participants dan createdAt
        await chatDoc.set({
          'participants': [
            FirebaseAuth.instance.currentUser!.email, // Email user login
            widget.contactEmail // Email kontak tujuan
          ],
          'createdAt': FieldValue.serverTimestamp(), // Timestamp otomatis
        });
        debugPrint("Chat document created successfully.");
      }

      // Tambahkan pesan ke subcollection 'messages'
      final message = {
        'senderId': _currentUserId,
        'receiverId': widget.contactId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(), // Timestamp otomatis
        'isRead': false, // Menandai pesan belum dibaca
      };

      debugPrint("Sending message: $message");
      await chatDoc.collection('messages').add(message);
      debugPrint("Message sent successfully.");

      _messageController.clear();
    } catch (e) {
      debugPrint("Error in _sendMessage: $e");
    }
  }

  /// Mendapatkan chatId berdasarkan userAId dan userBId
  String _getChatId(String userAId, String userBId) {
    return userAId.compareTo(userBId) < 0
        ? '$userAId$userBId'
        : '$userBId$userAId';
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _getChatId(_currentUserId, widget.contactId);
    debugPrint("Building chat screen for chatId: $chatId");

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.contactImage.isNotEmpty
                  ? NetworkImage(widget.contactImage)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName),
                Text(
                  widget.contactEmail,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  debugPrint("No messages found for chatId: $chatId");
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == _currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue[200]
                              : Colors.grey[300], // Warna bubble
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message['content']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
