import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:empedu/services/chat_services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUid; // UID penerima
  final String receiverEmail; // Email penerima

  const ChatScreen(
      {Key? key, required this.receiverUid, required this.receiverEmail})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late String _chatId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Jika pengguna belum login, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Generate chatId berdasarkan UID pengirim dan penerima
      _chatId =
          _chatService.generateChatId(currentUser.uid, widget.receiverUid);
    }
  }

  // Kirim pesan
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _chatService.sendMessage(message, widget.receiverUid);
          _messageController.clear();
        }
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat mengirim pesan')),
        );
      }
    }
  }

  // Tandai pesan sebagai sudah dibaca
  void _markMessageAsRead(DocumentSnapshot messageDoc) async {
    if (!messageDoc['isRead'] &&
        messageDoc['receiver'] == FirebaseAuth.instance.currentUser!.uid) {
      await messageDoc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverUid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text("User not found");
            }

            var receiverData = snapshot.data!.data() as Map<String, dynamic>;

            // Pastikan key 'name' ada dan valid
            String receiverName = receiverData['name'] ?? "No name available";

            return Text(receiverName); // Tampilkan nama atau fallback
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService
                  .getMessages(_chatId), // Mendapatkan pesan berdasarkan chatId
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isSender = messageData['sender'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    // Tandai pesan sebagai sudah dibaca
                    _markMessageAsRead(messageData);

                    return MessageBubble(
                      message: messageData['message'],
                      isSender: isSender,
                      isRead: messageData['isRead'],
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
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final bool isRead;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSender,
    required this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Material(
                color: isSender ? Colors.blueAccent : Colors.grey[300]!,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: isSender ? Colors.white : Colors.black,
                        ),
                      ),
                      if (!isRead && !isSender)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Icon(
                            Icons.circle,
                            size: 8.0,
                            color: Colors
                                .red, // Menunjukkan bahwa pesan belum dibaca
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
