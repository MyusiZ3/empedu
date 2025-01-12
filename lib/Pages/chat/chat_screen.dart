// Ini dah fixxxxx jangan diubah
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverEmail;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.receiverEmail,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xff0d1b34)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/default_avatar.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff0d1b34),
                  ),
                ),
                Text(
                  widget.receiverEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Membuat daftar pesan
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return const Center(
            child: Text('No messages yet. Start the conversation!'),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message['senderId'] == _currentUser?.email;
            final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
            final formattedTime = timestamp != null
                ? DateFormat('hh:mm a').format(timestamp)
                : 'Sending...';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xff898de8) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMe ? 10 : 0),
                      topRight: Radius.circular(isMe ? 0 : 10),
                      bottomLeft: const Radius.circular(15),
                      bottomRight: const Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Membuat input pesan
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xfff5f5f5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: const Color(0xff898de8),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Fungsi untuk mengirim pesan
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = {
      'senderId': _currentUser?.email,
      'receiverId': widget.receiverEmail,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    try {
      final chatDocRef = FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.chatRoomId);

      final chatDocSnapshot = await chatDocRef.get();
      if (!chatDocSnapshot.exists) {
        await chatDocRef.set({
          'participants': [_currentUser?.email, widget.receiverEmail],
          'lastMessage': '',
          'lastTimestamp': FieldValue.serverTimestamp(),
        });
      }

      await chatDocRef.collection('chats').add(message);

      await chatDocRef.update({
        'lastMessage': _messageController.text.trim(),
        'lastTimestamp': FieldValue.serverTimestamp(),
      });

      // Tambahkan otomatis ke daftar kontak pengirim dan penerima
      await _autoAddContact(_currentUser!.email!, widget.receiverEmail);

      _messageController.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  /// Fungsi auto-add kontak
  Future<void> _autoAddContact(String senderEmail, String receiverEmail) async {
    try {
      final senderDoc =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      final receiverQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: receiverEmail)
          .get();

      // Tambahkan ke kontak sender
      await senderDoc.set(
        {
          'contacts': FieldValue.arrayUnion([receiverEmail])
        },
        SetOptions(merge: true),
      );

      // Tambahkan ke kontak receiver
      if (receiverQuery.docs.isNotEmpty) {
        final receiverDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(receiverQuery.docs.first.id);
        await receiverDoc.set(
          {
            'contacts': FieldValue.arrayUnion([senderEmail])
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Error auto-adding contact: $e');
    }
  }
}
